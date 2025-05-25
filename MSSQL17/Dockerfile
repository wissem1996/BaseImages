FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive \
    ACCEPT_EULA=Y \
    PATH=$PATH:/opt/mssql-tools/bin

# Install dependencies and Microsoft repo
RUN apt-get update && \
    apt-get install -y \
        curl \
        tar \
        gzip \
        mailutils \
        python3 \
        python3-pip \
        krb5-user \
        libkrb5-dev \
        passwd \
        findutils \
        unzip \
        hostname \
        less \
        procps \
        ca-certificates \
        gcc \
        libffi-dev \
        libssl-dev \
        git \
        make \
        gnupg && \
    rm -rf /var/lib/apt/lists/*

# Install mssql-tools (sqlcmd)
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64] https://packages.microsoft.com/debian/10/prod buster main" > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
    rm -rf /var/lib/apt/lists/* microsoft.gpg

# Install AWS CLI
RUN pip3 install --no-cache-dir awscli

# Default entrypoint
ENTRYPOINT ["/bin/bash"]
