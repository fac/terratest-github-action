FROM golang:1.21-bookworm

# As of v1.16 module-aware mode is enabled by default, regardless of whether a go.mod file is present in the current working directory or a parent directory.
# More precisely, the GO111MODULE environment variable now defaults to on.
ENV GO111MODULE auto

RUN apt-get update && apt-get --no-install-recommends -y install \
    git \
    unzip

# Install gotestsum for parsing test output
RUN curl -sSL "https://github.com/gotestyourself/gotestsum/releases/download/v1.9.0/gotestsum_1.9.0_linux_amd64.tar.gz" | tar -xz -C /usr/local/bin gotestsum

# Install awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Install packer
RUN curl "https://releases.hashicorp.com/packer/1.8.5/packer_1.8.5_linux_amd64.zip" -o "packer.zip" && \
    unzip packer.zip && \
    mv packer /usr/local/bin && \
    chmod a+x /usr/local/bin/packer

# Install the SSM Session Plugin for AMI builds
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb

RUN git clone -b v3.0.0 https://github.com/tfutils/tfenv.git ~/.tfenv
RUN echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile && ln -s ~/.tfenv/bin/* /usr/local/bin
RUN tfenv install 1.3.4

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

