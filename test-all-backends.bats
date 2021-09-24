setup_file() {
    docker-compose down -v
    docker-compose up -d db
    docker-compose build test
}

setup() {
    echo "setup"
    load 'node_modules/bats-assert/load'
    load 'node_modules/bats-support/load'
}

@test "Python" {
    echo "# Python" >&3
    export TRY_CB_BACKEND=python
    docker-compose build backend
    echo "# Up" >&3
    docker-compose up -d backend
    echo "# Up2" >&3
    docker-compose up --exit-code-from test test
    echo "# Done" >&3
}

@test "Ruby" {
    echo "# Ruby" >&3
    export TRY_CB_BACKEND=ruby
    docker-compose build backend
    echo "# Up" >&3
    docker-compose up -d backend
    echo "# Up2" >&3
    docker-compose up --exit-code-from test test
    echo "# Done" >&3
}

@test "Node.js" {
    echo "# Node.js" >&3
    export TRY_CB_BACKEND=nodejs
    docker-compose build backend
    echo "# Up" >&3
    docker-compose up -d backend
    echo "# Up2" >&3
    docker-compose up --exit-code-from test test
    echo "# Done" >&3
}



teardown() {
    echo "teardown"
    docker-compose rm -s -v backend
}

teardown_file() {
    docker-compose down -v
}
