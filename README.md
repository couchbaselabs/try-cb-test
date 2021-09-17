# Couchbase travel-sample Application REST test-suite

This is the test suite for the REST backend of the travel-sample apps.
In the near future you will run the tests from each travel-sample app, which will then create this tester.

For now, see below for how to run from this repo.

## Prerequisites

To download the test suite you can either download [the archive](https://github.com/couchbaselabs/try-cb-test/archive/main.zip) or clone the repository:

```
git clone https://github.com/couchbaselabs/try-cb-test.git
```

We recommend running the application with Docker, which starts up all components for you.

## Running the application with Docker

You will need [Docker](https://docs.docker.com/get-docker/) installed on your machine in order to run this application as we have defined a [_Dockerfile_](Dockerfile) and a [_docker-compose.yml_](docker-compose.yml) to run Couchbase Server 7.0.0
and one of the backend REST APIs (by default the Python one)

To launch the test suite you can simply run this command from a terminal:

    $ docker-compose up test

You will get output along the following lines:

    Creating network "try-cb-test_default" with the default driver
    Creating test-couchbase-sandbox-7.0.0 ... done
    Creating test-try-cb-api              ... done
    Creating try-cb-test_test_1           ... done
    Attaching to try-cb-test_test_1
    test_1     | wait-for-it: waiting 400 seconds for backend:8080
    test_1     | wait-for-it: backend:8080 is available after 79 seconds
    test_1     | 1..3
    test_1     | ok 1 /api/airports
    test_1     | ok 2 /api/flightPaths/{fromloc}/{toloc}
    test_1     | ok 3 /api/hotels/{description}/{location}/
    try-cb-test_test_1 exited with code 0

To turn off the server run

    $ docker-compose down -v

## Running the tests locally

You can start a REST server with:

    $ docker-compose up backend

(Or run one in mix-and-match style as documented in the relevant project)

Then install `bats` with:

    $ npm install
    $ npm install -g bats

If your server is not running on the default localhost:8080, you can set an environment variable:

    # Example only
    $ BACKEND_BASE_URL=http://node1.example.com:8080

And run the tests with:

    $ bats travel-sample-backend.bats
