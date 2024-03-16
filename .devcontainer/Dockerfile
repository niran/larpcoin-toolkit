FROM mcr.microsoft.com/devcontainers/typescript-node

RUN apt update && apt upgrade -y
RUN apt install -y xxd

USER node
RUN curl -L https://foundry.paradigm.xyz | bash
RUN /home/node/.foundry/bin/foundryup
