# Set the base image to Node
FROM node:15-buster-slim

LABEL maintainer="Couchbase"

WORKDIR /usr/app
COPY ./ /usr/app

RUN apt-get update && apt-get install -y wait-for-it curl jq

RUN npm install
RUN npm install -g bats

CMD bats travel-sample-backend.bats
