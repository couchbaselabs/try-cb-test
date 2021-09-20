setup_file() {
    export TRYCB_USER=$(mktemp tmpuserXXXX)
    jq ".user=\"${TRYCB_USER}\"" user.json > $TRYCB_USER
}

setup() {
    load 'node_modules/bats-assert/load'
    load 'node_modules/bats-support/load'
    load 'test-helpers'
}

@test "GET /api/airports" {
    get '/api/airports?search=FLO'
    
    status_is 200
    
    jq_ok '.context[0] | startswith("N1QL query - scoped to inventory")'

    jq_is 'Florence Rgnl' '.data[0].airportname'
}

@test "GET /api/flightPaths/{fromloc}/{toloc}" {
    get '/api/flightPaths/Los%20Angeles%20Intl/San%20Francisco%20Intl?leave=05/24/2021'
    
    status_is 200
    
    jq_ok '.context[0] | startswith("N1QL query - scoped to inventory")'
    
    jq_ok '.data | length > 0'
    jq_ok '.data | all(.sourceairport == "LAX")'
    jq_ok '.data | all(.destinationairport == "SFO")'
}

@test "GET /api/hotels/{description}/{location}/" {
    get '/api/hotels/pool/San%20Francisco/'
    
    status_is 200
    
    jq_ok '.context[0] | startswith("FTS search - scoped to: inventory.hotel")'
    jq_ok '.data | any(.name == "Ritz-Carlton San Francisco")'
}

@test "POST /api/tenants/{tenant}/user/signup" {
    diag "Signing up user $TRYCB_USER"
    post '/api/tenants/tenant_agent_00/user/signup' \
        -d @$TRYCB_USER

    status_is 201
    jq_ok '.context[0] | startswith("KV insert - scoped to tenant_agent_00.users:")'
    jq_ok '.data.token | length > 0'

    jq_get '.data.token' > user.token

    diag "Subsequent create returns 409 conflict"
    post '/api/tenants/tenant_agent_00/user/signup' \
        -d @$TRYCB_USER

    status_is 409
}

@test "POST /api/tenants/{tenant}/user/login" {
    diag "Logging in user $TRYCB_USER"
    post '/api/tenants/tenant_agent_00/user/login' \
        -d @$TRYCB_USER

    status_is 200
    jq_ok '.context[0] | startswith("KV get - scoped to tenant_agent_00.users:")'
    jq_ok '.data.token | length > 0'

    jq_get '.data.token' > user.token
}

@test "GET /api/tenants/{tenant}/user/{username}/flights List the flights that have been reserved by a user" {
    skip "Doesn't work for Python in empty case"
    get "/api/tenants/tenant_agent_00/user/${TRYCB_USER}/flights" \
        -H "$(auth)"
        
    status_is 200
}

@test "PUT /api/tenants/{tenant}/user/{username}/flights Book a flight for a new user" {
    put "/api/tenants/tenant_agent_00/user/${TRYCB_USER}/flights" \
        -H "$(auth)" \
        -d @flight1.json
        
    status_is 200
    jq_ok '.context[0] | startswith("KV update - scoped to tenant_agent_00.user:")'
    jq_is 1 '.data.added | length'

    diag "Booking second flight"
    put "/api/tenants/tenant_agent_00/user/${TRYCB_USER}/flights" \
        -H "$(auth)" \
        -d @flight2.json
        
    status_is 200
}

@test "GET /api/tenants/{tenant}/user/{username}/flights redux" {
    get "/api/tenants/tenant_agent_00/user/${TRYCB_USER}/flights" \
        -H "$(auth)"
        
    status_is 200
    jq_ok '.context[0] | startswith("KV get - scoped to tenant_agent_00.user:")'
    jq_is 2 '.data | length'
}

teardown_file() {
    rm $TRYCB_USER
}
