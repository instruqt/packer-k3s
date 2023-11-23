FROM hashicorp/packer:latest

ARG K3S_VERSION=''

RUN apk update; apk upgrade; 
RUN apk add curl jq make

COPY ./files/* ./files/
COPY ./Makefile ./
COPY ./version.sh ./
COPY ./k3s.pkr.hcl ./

RUN packer init k3s.pkr.hcl

ENTRYPOINT ["./version.sh"]