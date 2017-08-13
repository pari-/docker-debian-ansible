#!/bin/bash

#
# run.sh - Ansible Role Testing on steroids! ;-) 
#

R='\033[31;1m'
G='\033[32;1m'
N='\033[0m'

function run_cmd() {
	CONTAINER_NAME=$1
	CMD=${*:2}
	
	printf "$ %s\n" "$CMD"
	eval "$CMD"
	exit_code="$?"
	if [ "$exit_code" == "0" ]
	then
		printf "\n"${G}"The command \"%s\" exited with 0.\n\n"${N} "$CMD"
	elif [ "$?" == "1" ] || [ "$?" == "2" ]
	then
		printf "\n"${R}"The command \"%s\" failed with $exit_code.\n\n"${N} "$CMD"
		LEFTOVER_CONTAINER=$(docker ps -f name="${CONTAINER_NAME}" -q)
		if [ -n "${LEFTOVER_CONTAINER}" ] && [ "${CLEANUP}" = true ]; then
			docker stop "${LEFTOVER_CONTAINER}"
			docker rm -f "${LEFTOVER_CONTAINER}"
		fi
		exit "$exit_code"
	fi
}

function main() {
	#
	# variable control defaults
	#
	IMAGE=${IMAGE:-"irap/docker-debian-ansible"}
	PLAYBOOK=${PLAYBOOK:-"test.yml"}
	CLEANUP=${CLEANUP:-"true"}

	#
	#
	# internals
	CONTAINER_ID=$(date +%s)
	REMOTE_ROLE_PATH="/etc/ansible/roles"
	ROLE_NAME=""
	LOCAL_ROLE_PATH=""

	#
	# Debian GNU/Linux (jessie) specifics
	#
	INIT="/lib/systemd/systemd"
	OPTS="--privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"

	#
	# Environment specifics
	#
	if [ -n "${TRAVIS_REPO_SLUG}" ];
	then
		#
		# right, we seem to be on TravisCI
		#
		ROLE_NAME=$(basename "${TRAVIS_REPO_SLUG}")
	else
		#
		# seemingly not a TravisCI build
		#
		run_cmd "${CONTAINER_ID}" "printenv GIT_REPO_URL && printenv ANSIBLE_VERSION"
		ROLE_NAME=$(basename "${GIT_REPO_URL}" ".git")
		run_cmd "${CONTAINER_ID}" "git clone ${GIT_REPO_URL} ${ROLE_NAME}"
		cd "${ROLE_NAME}"
		if [ -n "${BRANCH}" ]; then
			run_cmd "${CONTAINER_ID}" "git checkout ${BRANCH}"
		fi
	fi

	LOCAL_ROLE_PATH="$PWD"
	
	#
	# pull the docker image
	#
	run_cmd "${CONTAINER_ID}" "docker pull ${IMAGE}"

	#
	# run the docker image and mount the previously cloned repo
	#
	run_cmd "${CONTAINER_ID}" "docker run --detach --volume=${LOCAL_ROLE_PATH}:${REMOTE_ROLE_PATH}/${ROLE_NAME}:rw --name ${CONTAINER_ID} ${OPTS} ${IMAGE} ${INIT}"

	CONTAINER_PATH_VAR="$(docker exec --tty ${CONTAINER_ID} printenv -0 | sed -e 's/.*PATH=\([^\x0]\+\)\x0.*/\1/')"

	#
	# check if there are any requirements to pull in, if yes: do so 
	#
	if [ -f "${LOCAL_ROLE_PATH}/requirements.yml" ]; then
		run_cmd "${CONTAINER_ID}" "docker exec --tty ${CONTAINER_ID} env PATH=/opt/ansible-${ANSIBLE_VERSION}/bin:$CONTAINER_PATH_VAR TERM=xterm ANSIBLE_CONFIG=/etc/ansible/roles/${ROLE_NAME}/ansible.cfg ansible-galaxy install -r ${REMOTE_ROLE_PATH}/${ROLE_NAME}/requirements.yml"
	fi
	
	#
	# perform a basic syntax-check and list tasks
	#
	run_cmd "${CONTAINER_ID}" "docker exec --tty ${CONTAINER_ID} env PATH=/opt/ansible-${ANSIBLE_VERSION}/bin:$CONTAINER_PATH_VAR TERM=xterm ANSIBLE_CONFIG=/etc/ansible/roles/${ROLE_NAME}/ansible.cfg ansible-playbook ${REMOTE_ROLE_PATH}/${ROLE_NAME}/test.yml -i localhost, --syntax-check --list-tasks --sudo"

	#
	# run the playbook
	#
	run_cmd "${CONTAINER_ID}" "docker exec --tty ${CONTAINER_ID} env PATH=/opt/ansible-${ANSIBLE_VERSION}/bin:$CONTAINER_PATH_VAR TERM=xterm ANSIBLE_CONFIG=/etc/ansible/roles/${ROLE_NAME}/ansible.cfg ansible-playbook ${REMOTE_ROLE_PATH}/${ROLE_NAME}/test.yml -i localhost, -c local -s -vvvv --sudo"

	#
	# check for idempotence
	#
	TMP_DIR="$(mktemp)"
	run_cmd "${CONTAINER_ID}" "docker exec --tty ${CONTAINER_ID} env PATH=/opt/ansible-${ANSIBLE_VERSION}/bin:$CONTAINER_PATH_VAR TERM=xterm ANSIBLE_CONFIG=/etc/ansible/roles/${ROLE_NAME}/ansible.cfg ansible-playbook ${REMOTE_ROLE_PATH}/${ROLE_NAME}/test.yml -i localhost, -c local -s | tee ${TMP_DIR}; grep -q 'changed=0.*failed=0' ${TMP_DIR} && (echo 'Idempotence? ... PASS!' && exit 0) || (echo 'Idempotence? ... FAIL!' && exit 1)"

	#
	# if configured, clean up "the mess"! ;-)
	#
	if [ "${CLEANUP}" = true ]; then
		docker rm -f "${CONTAINER_ID}"
		rm -rf "${TMP_DIR}"
	fi
}

main 
