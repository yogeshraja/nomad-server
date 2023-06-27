#!/usr/bin/env bash

{
NAME="nomadserver"
GIT_REPO_URL="https://github.com/yogeshraja/nomad-server.git"
GIT_SSH_URL="git@github.com:yogeshraja/nomad-server.git"
INSTALL_DIR="/opt/nomad-server"

if_has() {
    type "$1" >/dev/null 2>&1
}

term_echo() {
    command printf %s\\n "$*" 2>/dev/null
}

check_dependency() {
    term_echo "Checking dependencies ...."
    dependencies=("nomad" "consul" "docker" "git")
    for dependency in "${dependencies[@]}"; do
        if ! if_has "${dependency}"; then
            echo "${dependency} not found"
            exit 1
        fi
    done
}

check_root() {
    term_echo "Checking root access ...."
    local uid
    uid="$(id -u)"
    term_echo "User id : ${uid}"
    if ! [[ ${uid} == 0 ]]; then
        term_echo "Seems like you are not root"
        term_echo "please run the command with sudo"
        exit 1
    fi
}

create_required_folders() {
    term_echo "Creating folders for installing the service ...."
    mkdir -p "${INSTALL_DIR}"                            # Create nomad server
    mkdir -p "${INSTALL_DIR}/nomad/deploy"               # Nomad data dir
    mkdir -p "${INSTALL_DIR}/nomad_volumes/local-volume" # Dir for nomad volumes
    mkdir -p "/var/log/nomadserver"                      # Dir for service logs
}

clone_using_git() {
    git clone "${GIT_REPO_URL}" "${INSTALL_DIR}/"
}

install_service() {
    term_echo "Installing nomadserver service ...."
    cp -f "${INSTALL_DIR}/scripts/${NAME}" "/etc/init.d/"
    chmod 751 "/etc/init.d/${NAME}"
    update-rc.d nomadserver defaults
    cat <<EOF >>"/etc/default/${NAME}"
USER="${SUDO_USER}"
EOF
}

own_folders_recursively() {
    term_echo "Changing ownership of all files and directories in /opt/nomadserver ...."
    chown -R "${SUDO_USER}" "${INSTALL_DIR}"
}

start_service(){
    service "${NAME}" start
}

do_install() {
    check_dependency
    check_root
    clone_using_git
    create_required_folders
    install_service
    own_folders_recursively
    start_service
}

do_install

}
