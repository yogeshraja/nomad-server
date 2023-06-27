#!/usr/bin/env bash

{

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
    dependencies=("nomad" "consul" "docker" "git")
    for dependency in "${dependencies[@]}"; do
        if ! if_has "${dependency}"; then
            echo "${dependency} not found"
            exit 1
        fi
    done
}

elevate_to_root() {
    local uid
    uid="$(id -u)"
    if ! [[ ${uid} == 0 ]]; then
        sudo su root
    fi
}

create_required_folders() {
    term_echo "Creating folders for installing the service"
    mkdir -p "${INSTALL_DIR}"                            # Create nomad server
    mkdir -p "${INSTALL_DIR}/nomad/deploy"               # Nomad data dir
    mkdir -p "${INSTALL_DIR}/nomad_volumes/local-volume" # Dir for nomad volumes
}

clone_using_git() {
    git clone "${GIT_REPO_URL}" "${INSTALL_DIR}/"
}

install_service() {
    cp "${INSTALL_DIR}/scripts/${NAME}" "/etc/init.d/"
    chmod 751 "/etc/init.d/${NAME}"
    update-rc.d nomadserver defaults
    cat <<EOF >>"/etc/default/${NAME}"
USER="${SUDO_USER}"
EOF
}

own_folders_recursively() {
    chown -R "${SUDO_USER}" "${INSTALL_DIR}"
}

start_service(){
    service "${NAME}" start
}

do_install() {
    check_dependency
    elevate_to_root
    create_required_folders
    clone_using_git
    install_service
    own_folders_recursively
    start_service
}

do_install

}
