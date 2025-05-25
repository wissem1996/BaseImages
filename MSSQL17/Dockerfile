FROM mcr.microsoft.com/mssql/server:2017-latest

# Set environment variables early
ENV ACCEPT_EULA=Y \
    SA_PASSWORD=ChangeIt!12345 \
    DEBIAN_FRONTEND=noninteractive \
    PATH=$PATH:/root/.local/bin

# Use a non-root user (SQL Server runs as root by default, but see notes below)
USER root

# Install only required packages with microdnf (UBI uses microdnf)
RUN apt-get update -y && \
        apt-get install -y \
        python3 \
        python3-pip \
        mailutils \
        curl \
        unzip \
        ca-certificates \
        gnupg2 \
        krb5-user \
        libkrb5-dev \
        less && \      
    pip3 install --no-cache-dir awscli && \
    apt-get clean all && \
    rm -rf /root/.cache /var/cache/yum
EXPOSE 1433

# SQL Server entrypoint
CMD ["/opt/mssql/bin/sqlservr"]
