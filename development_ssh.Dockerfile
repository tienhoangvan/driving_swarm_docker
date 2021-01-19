FROM ovgudrivingswarm/development:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG DIR_SSH=ssh

USER root


# copy ssh-keys etc.

COPY development/"$DIR_SSH"/* /home/docker/.ssh/
RUN chown -R docker /home/docker

USER docker
