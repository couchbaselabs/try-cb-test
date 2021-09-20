http() {
    echo curl
    for var in "$@"
    do
        echo ".    $var"
    done
    curl "$@" -D out.head >out.body 2>/dev/null
}

call() {
    BACKEND_BASE_URL="${BACKEND_BASE_URL:-http://localhost:8080}"
    path=$1
    shift
    http "$@" -H "accept: application/json" "${BACKEND_BASE_URL}${path}"
}

get() {
    call "$@" -X GET
}

post() {
    call "$@" -H "Content-Type: application/json" -X POST
}

put() {
    call "$@" -H "Content-Type: application/json" -X PUT
}

auth() {
    TOKEN=$(<user.token)
    echo "Authorization: Bearer $TOKEN"
}

status_is() {
    expected=$1
    output=$(head -n 1 out.head | cut -d' ' -f2)
    assert_output "$expected" || \
        (
            diag_file out.head
            # diag_file out.body
            false
        )
}

jq_get() {
    jq -r "$@" out.body
}

jq_is() {
    expected=$1
    shift
    run jq_get "$@"
    assert_output "$expected" 
        
}

jq_ok() {
    jq_is true "$@" || \
        (
            diag "Expected jq: $@"
            diag_file out.body
            false
        )
}

diag() {
    printf ' # %s\n' "$@" >&3

    #echo " # $@" >&3
}

diag_file() {
    while IFS="" read -r p || [ -n "$p" ]
    do
        diag "$p"
    done < $1
}
