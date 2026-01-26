#!/usr/bin/env bash

if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

# Function to generate .env file
generate_env_file() {
    profile="${1:-}"
    hostname="${2:-}"
    https="${3:-}"

    if [[ -f "${profile}.env" ]]; then
        datakey="$(grep "DATA_ENCRYPTION_KEY" "${profile}.env" | cut -d= -f2)"
    else
        datakey=$(openssl rand -hex 16)
    fi

    cp ".env" "${profile}.env"
    echo "copy .env file for profile: ${profile}.env"

    if [[ "$profile" == "aio" ]]; then
        # remove lines for FRONTEND_PORT ADMIN_PORT BACKEND_PORT APP_PORT
        sed -i '/^FRONTEND_PORT/d' "${profile}.env"
        sed -i '/^ADMIN_PORT/d' "${profile}.env"
        sed -i '/^BACKEND_PORT/d' "${profile}.env"

        # ENABLE_SUBPATH_BASED_ACCESS=false
        sed -i 's/^ENABLE_SUBPATH_BASED_ACCESS=.*/ENABLE_SUBPATH_BASED_ACCESS=true/' "${profile}.env"

        if [[ -n "$hostname" ]]; then
            # set backend url
            sed -i "s@localhost:3000@${hostname}@g" "${profile}.env"
            sed -i "s@localhost:3100@${hostname}/admin@g" "${profile}.env"
            sed -i "s@localhost:3170@${hostname}/backend@g" "${profile}.env"
        fi
    elif [[ "$profile" == "one" ]]; then
        # remove AIO_PORT
        sed -i '/^AIO_PORT/d' "${profile}.env"


        if [[ -n "$hostname" ]]; then
            # set backend url
            sed -i "s@localhost:@${hostname}:@g" "${profile}.env"
        fi
    fi

    # DATA_ENCRYPTION_KEY
    sed -i "s/^DATA_ENCRYPTION_KEY=.*/DATA_ENCRYPTION_KEY=$datakey/" "${profile}.env"

    # https
    if [[ -n "$https" ]]; then
        sed -i "s@http://@https://@g" "${profile}.env"
    fi

    echo "${profile}.env file generated successfully."
}

main() {
    # Main script
    if [ -z "${1:-}" ]; then
    echo "Usage: $0 [aio|one]"
    exit 1
    fi

    generate_env_file "$@"
}

main "$@"
