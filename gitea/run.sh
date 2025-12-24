#!/usr/bin/env bash

load_vars() {
    DOWN_URL="https://framagit.org/jetsung/awesome-compose/-/raw/main/gitea/run.sh"
    DOWN_URL=${DOWN_URL%/*}
}

download_files() {
    local FILES="README.md compose.yaml compose.override.yaml Caddyfile nginx.conf run.sh .env"
    for FILE in ${FILES}; do
        if [ ! -f "${FILE}" ]; then
            echo "Fetching file '${FILE}'"
            wget -q "${DOWN_URL}/${FILE}"
        fi
    done
}

check_docker() {
    local CHECK_CMD
    CHECK_CMD=$(docker compose version 2>&1)

    if [[ "${CHECK_CMD}" =~ "not" ]]; then
        echo "${CHECK_CMD}"
        exit 1
    fi
}

all_start_caddy() {
    docker compose --profile caddy up -d
}

all_stop_caddy() {
    docker compose --profile caddy down
}

all_start_nginx() {
    docker compose --profile nginx up -d
}

all_stop_nginx() {
    docker compose --profile nginx down
}

first_install() {
    load_vars

    check_docker

    download_files

    if [[ -z "${1}" ]]; then
        docker compose up -d
    else
        sed -i "s/[^#]\- 3000/\#\- 3000/" ./compose.yaml
        sed -i "s/.*{/${1} {/" ./Caddyfile
        all_start_caddy
    fi
}

second_update() {
    DOMAIN="${1}"

    if [[ -n "${DOMAIN}" ]]; then

        sed -i "s/localhost/${DOMAIN}/" ./gitea/gitea/conf/app.ini
        sed  -ri "s/(ROOT_URL\s*\= ).*/\1https:\/\/${DOMAIN}\//" ./gitea/gitea/conf/app.ini

        if [[ "${2}" = "nginx" ]]; then
            sed -ri "s/(server_name ).*/\1${DOMAIN};/" nginx.conf
            all_start_nginx
            docker compose restart nginx
        else
            sed -i "s/.*{/${DOMAIN} {/" ./Caddyfile
            all_start_caddy
            docker compose restart caddy
        fi
    fi
}

update_drone_files() {
    load_vars
    DOWN_URL="${DOWN_URL%/*}/drone"

    local DRONE_ENV=".env_drone"
    if [[ ! -f "${DRONE_ENV}" ]]; then
        local ENV_FILE=".env"
        printf "Fetching file drone '%s'\n" "${ENV_FILE}"
        wget -qO "${DRONE_ENV}" "${DOWN_URL}/${ENV_FILE}"
    fi

    local DOCKER_COMPOSE="docker-compose.drone.yaml"
    if [[ ! -f "${DOCKER_COMPOSE}" ]]; then
        local COMPOSE_FILE="docker-compose.yaml"
        printf "Fetching file drone '%s'\n" "${COMPOSE_FILE}"
        wget -qO "${DOCKER_COMPOSE}" "${DOWN_URL}/${COMPOSE_FILE}"
    fi

    # set drone docker-compose.drone.yaml file
    sed -i "s/\- \.\/\.env.*/\- \.\/\.env_drone/" "${DOCKER_COMPOSE}"
    sed -i "/ports/d;/\- 80\:80/d;/\- 443\:443/d" "${DOCKER_COMPOSE}"

    # set drone .env file
    sed -ri "s#(DRONE_GITEA_SERVER=).*#\1${DRONE_GITEA_SERVER}#" "${DRONE_ENV}"
    sed -ri "s#(DRONE_GITEA_CLIENT_ID=).*#\1${DRONE_GITEA_CLIENT_ID}#" "${DRONE_ENV}"
    sed -ri "s#(DRONE_GITEA_CLIENT_SECRET=).*#\1${DRONE_GITEA_CLIENT_SECRET}#" "${DRONE_ENV}"
    sed -ri "s#(DRONE_RPC_SECRET=).*#\1${DRONE_RPC_SECRET}#" "${DRONE_ENV}"
    sed -ri "s#(DRONE_SERVER_HOST=).*#\1${DRONE_SERVER_HOST}#" "${DRONE_ENV}"

    if grep -q "${DRONE_SERVER_HOST}" ./Caddyfile;then
        tee -a ./Caddyfile << EOF

${DRONE_SERVER_HOST} {
    tls mygit@outlook.com
    reverse_proxy drone-server:80
}
EOF
    fi

    all_start_caddy
    docker compose -f "${DOCKER_COMPOSE}" up -d
    docker compose restart caddy
}

update_woodpecker_files() {
    load_vars
    DOWN_URL="${DOWN_URL%/*}/woodpecker"

    local WOODPECKER_ENV=".env_woodpecker"
    if [[ ! -f "${WOODPECKER_ENV}" ]]; then
        local ENV_FILE=".env"
        printf "Fetching file woodpecker '%s'\n" "${ENV_FILE}"
        wget -qO "${WOODPECKER_ENV}" "${DOWN_URL}/${ENV_FILE}"
    fi

    local DOCKER_COMPOSE="docker-compose.woodpecker.yaml"
    if [[ ! -f "${DOCKER_COMPOSE}" ]]; then
        local COMPOSE_FILE="docker-compose.yaml"
        printf "Fetching file woodpecker '%s'\n" "${COMPOSE_FILE}"
        wget -qO "${DOCKER_COMPOSE}" "${DOWN_URL}/${COMPOSE_FILE}"
    fi

    # set woodpecker docker-compose.drone.yaml file
    sed -i "s/\- \.\/\.env.*/\- \.\/\.env_woodpecker/" "${DOCKER_COMPOSE}"
    sed -i "/ports/d;/\- 8000\:8000/d" "${DOCKER_COMPOSE}"

    # set woodpecker .env file
    sed -ri "s#(WOODPECKER_GITEA_URL=).*#\1${WOODPECKER_GITEA_URL}#" "${WOODPECKER_ENV}"
    sed -ri "s#(WOODPECKER_GITEA_CLIENT=).*#\1${WOODPECKER_GITEA_CLIENT}#" "${WOODPECKER_ENV}"
    sed -ri "s#(WOODPECKER_GITEA_SECRET=).*#\1${WOODPECKER_GITEA_SECRET}#" "${WOODPECKER_ENV}"
    sed -ri "s#(WOODPECKER_AGENT_SECRET=).*#\1${WOODPECKER_AGENT_SECRET}#" "${WOODPECKER_ENV}"
    sed -ri "s#(WOODPECKER_HOST=).*#\1https\:\/\/${WOODPECKER_HOST}#" "${WOODPECKER_ENV}"

    if grep -q "${WOODPECKER_HOST}" ./Caddyfile;then
        tee -a ./Caddyfile << EOF

${WOODPECKER_HOST} {
    tls mygit@outlook.com
    reverse_proxy woodpecker-server:8000
}
EOF
    fi

    all_start_caddy
    docker compose -f "${DOCKER_COMPOSE}" up -d
    docker compose restart caddy
}

install_drone() {
    if [[ $# -lt 3 ]]; then
        echo "Drone arguments must be greater than 2."
        exit 1
    fi

    DRONE_SERVER_HOST="${1}"
    shift
    DRONE_GITEA_CLIENT_ID="${1}"
    shift
    DRONE_GITEA_CLIENT_SECRET="${1}"
    DRONE_GITEA_SERVER=$(grep ROOT_URL ./gitea/gitea/conf/app.ini | awk '{print $3}')
    DRONE_GITEA_SERVER=${DRONE_GITEA_SERVER%/}
    DRONE_RPC_SECRET=$(openssl rand -hex 16)

    printf "DRONE_GITEA_SERVER: %s
DRONE_GITEA_CLIENT_ID: %s
DRONE_GITEA_CLIENT_SECRET: %s
DRONE_RPC_SECRET: %s
DRONE_SERVER_HOST: %s\n
" "${DRONE_GITEA_SERVER}" "${DRONE_GITEA_CLIENT_ID}" "${DRONE_GITEA_CLIENT_SECRET}" "${DRONE_RPC_SECRET}" "${DRONE_SERVER_HOST}"

    update_drone_files
}

install_woodpecker() {
    if [[ $# -lt 3 ]]; then
        echo "Woodpecker arguments must be greater than 2."
        exit 1
    fi

    WOODPECKER_HOST="${1}"
    shift
    WOODPECKER_GITEA_CLIENT="${1}"
    shift
    WOODPECKER_GITEA_SECRET="${1}"
    WOODPECKER_GITEA_URL=$(grep ROOT_URL ./gitea/gitea/conf/app.ini | awk '{print $3}')
    WOODPECKER_GITEA_URL=${WOODPECKER_GITEA_URL%/}
    WOODPECKER_AGENT_SECRET=$(openssl rand -hex 16)

    printf "WOODPECKER_GITEA_URL: %s
WOODPECKER_GITEA_CLIENT: %s
WOODPECKER_GITEA_SECRET: %s
WOODPECKER_AGENT_SECRET: %s
WOODPECKER_HOST: https://%s\n
" "${WOODPECKER_GITEA_URL}" "${WOODPECKER_GITEA_CLIENT}" "${WOODPECKER_GITEA_SECRET}" "${WOODPECKER_AGENT_SECRET}" "${WOODPECKER_HOST}"

    update_woodpecker_files
}

main() {
    if [[ ${#@} -eq 0 ]]; then
        echo "Gitea Initializing."
        first_install
        exit
    fi

    case "${1}" in
        cstop | stop_caddy)
            echo "stop caddy"
            all_stop_caddy
        ;;

        cstart | start_caddy)
            echo "start caddy"
            all_start_caddy
        ;;

        nstop | stop_nginx)
            echo "stop nginx"
            all_stop_nginx
        ;;

        nstart | start_nginx)
            echo "start nginx"
            all_start_nginx
        ;;

        init)
            shift
            echo "Gitea initialize with caddy."
            first_install "${1}"
        ;;

        drone)
            shift
            echo "Drone Initializing..."
            install_drone "$@"
        ;;

        woodpecker)
            shift
            echo "Woodpecker Initializing..."
            install_woodpecker "$@"
        ;;

        *)
            SERV_NAME="caddy"
            [[ "${2}" = "nginx" ]] && SERV_NAME="nginx"
            printf "domain: '${1}', start with %s.\n" "${SERV_NAME}"
            second_update "$@"
    esac
}

main "$@"
