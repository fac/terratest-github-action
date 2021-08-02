FROM golang:1.16-buster

# As of v1.16 module-aware mode is enabled by default, regardless of whether a go.mod file is present in the current working directory or a parent directory.
# More precisely, the GO111MODULE environment variable now defaults to on.
ENV GO111MODULE auto

RUN apt-get update && apt-get --no-install-recommends -y install \
    git \
    unzip \
    python3 \
    python3-setuptools \
    python3-pip \
    python3-venv \
    go-dep ;

# Install gotestsum for parsing test output
RUN curl -sSL "https://github.com/gotestyourself/gotestsum/releases/download/v1.7.0/gotestsum_1.7.0_linux_amd64.tar.gz" | tar -xz -C /usr/local/bin gotestsum

# Install awscli
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    python3 ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws;

# Install packer
RUN curl "https://releases.hashicorp.com/packer/1.4.5/packer_1.4.5_linux_amd64.zip" -o "packer.zip" && \
    unzip packer.zip && \
    mv packer /usr/local/bin && \
    chmod a+x /usr/local/bin/packer

RUN git clone -b v2.0.0-beta1 https://github.com/tfutils/tfenv.git ~/.tfenv
RUN echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile && ln -s ~/.tfenv/bin/* /usr/local/bin
RUN tfenv install 0.13.7

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

