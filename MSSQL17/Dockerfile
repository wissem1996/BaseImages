FROM registry.access.redhat.com/ubi8/ubi

ENV DEBIAN_FRONTEND=noninteractive \
    ACCEPT_EULA=Y \
    PATH=$PATH:/opt/mssql-tools/bin

# Install dependencies and Microsoft repo
RUN microdnf update -y && \
    microdnf install -y \
        curl \
        tar \
        gzip \
        mailx \
        python3 \
        python3-pip \
        krb5-workstation \
        krb5-libs \
        krb5-devel \
        shadow-utils \
        findutils \
        unzip \
        hostname \
        less \
        procps-ng \
        which \
        ca-certificates \
        gcc \
        libffi-devel \
        openssl-devel \
        git \
        make && \
    microdnf clean all

# Install mssql-tools (sqlcmd)
RUN curl -sSL https://packages.microsoft.com/config/rhel/8/prod.repo -o /etc/yum.repos.d/mssql-release.repo && \
    ACCEPT_EULA=Y microdnf install -y mssql-tools unixODBC-devel && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Install AWS CLI
RUN pip3 install --no-cache-dir awscli

# Clean up
RUN rm -rf /var/cache /root/.cache

# Default entrypoint (can be overridden)
ENTRYPOINT ["/bin/bash"]
