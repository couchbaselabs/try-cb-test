setup_file() {
    docker-compose down -v
    docker-compose up -d db
    docker-compose build test

    rm test-status
}

runTests() {
    export TRY_CB_BACKEND=$1
    echo "Testing $TRY_CB_BACKEND" | tee -a test-status
    
    echo building...
    docker-compose build backend
    
    echo upping...
    docker-compose up -d backend

    echo running test...
    if docker-compose up --exit-code-from test test
    then
        echo "ok $TRY_CB_BACKEND" | tee -a test-status
    else
        echo "not ok $TRY_CB_BACKEND" | tee -a test-status
    fi 
    echo >> test-status
    
    echo "teardown"
    docker-compose rm -s -f -v backend
}


teardown_file() {
    docker-compose down -v
    cat test-status
}

setup_file

runTests dotnet
runTests golang
runTests java
runTests nodejs
runTests php
runTests python
runTests ruby
runTests scala

teardown_file
