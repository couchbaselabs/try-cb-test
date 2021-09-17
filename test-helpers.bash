http() {
    curl -f $@ -D out.head >out.body 2>/dev/null
}

call() {
    BACKEND_BASE_URL="${BACKEND_BASE_URL:-http://localhost:8080}"
    path=$1
    shift
    http "${BACKEND_BASE_URL}${path}" $@
}

status_is() {
    expected=$1
    output=$(head -n 1 out.head | cut -d' ' -f2)
    assert_output "$expected"
}

jq_is() {
    expected=$1
    shift
    run jq -r "$@" out.body
    assert_output "$expected"
}

jq_ok() {
    jq_is true "$@"
}
