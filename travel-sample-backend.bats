setup() {
    load 'node_modules/bats-assert/load'
    load 'node_modules/bats-support/load'
    load 'test-helpers'
}

@test "/api/airports" {
    call '/api/airports?search=FLO'
    
    status_is 200
    
    jq_ok '.context[0] | startswith("N1QL query - scoped to inventory")'

    jq_is 'Florence Rgnl' '.data[0].airportname'
}

@test "/api/flightPaths/{fromloc}/{toloc}" {
    call '/api/flightPaths/Los%20Angeles%20Intl/San%20Francisco%20Intl?leave=05/24/2021'
    
    status_is 200
    
    jq_ok '.context[0] | startswith("N1QL query - scoped to inventory")'
    
    jq_ok '.data | length > 0'
    jq_ok '.data | all(.sourceairport == "LAX")'
    jq_ok '.data | all(.destinationairport == "SFO")'
}

@test "/api/hotels/{description}/{location}/" {
    call '/api/hotels/pool/San%20Francisco/'
    
    status_is 200
    
    jq_ok '.context[0] | startswith("FTS search - scoped to: inventory.hotel")'
    jq_ok '.data | any(.name == "Ritz-Carlton San Francisco")'
}
