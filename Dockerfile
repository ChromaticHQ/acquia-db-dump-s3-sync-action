# Container image that runs your code
FROM php:7-cli
RUN apt-get update \
    && apt-get --quiet --yes --no-install-recommends install \
      keychain \
      unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

# Acquia Connection Information
ARG INPUT_ACQUIA_ENVIRONMENT
ARG INPUT_ACQUIA_PROJECT
ARG INPUT_ACQUIA_PRIVATE_KEY
ARG INPUT_ACQUIA_PUBLIC_KEY
# AWS Connection Information
ARG INPUT_AWS_S3_BUCKET
ARG INPUT_AWS_ACCESS_KEY_ID
ARG INPUT_AWS_SECRET_ACCESS_KEY
ARG INPUT_AWS_DEFAULT_REGION

# Authorize SSH Host
RUN mkdir -p /github/home/.ssh && \
    chmod 0700 /github/home/.ssh && \
    touch /github/home/.ssh/known_hosts && \
    touch /github/home/.ssh/acquia && \
    touch /github/home/.ssh/acquia.pub && \
    ssh-keyscan acquia-sites.com > /github/home/.ssh/known_hosts

RUN  echo "    IdentityFile ~/.ssh/acquia" >> /etc/ssh/ssh_config
RUN ssh-keygen -A

# Add the keys and set permissions
RUN echo "$INPUT_ACQUIA_PRIVATE_KEY" > /github/home/.ssh/acquia && \
    echo "$INPUT_ACQUIA_PUBLIC_KEY" > /github/home/.ssh/acquia.pub && \
    chmod 644 /github/home/.ssh/acquia && \
    chmod 644 /github/home/.ssh/acquia.pub && \
    mkdir ~/.aws && \
    printf "[default]\naws_access_key_id=$INPUT_AWS_ACCESS_KEY_ID\naws_secret_access_key=$INPUT_AWS_SECRET_ACCESS_KEY" > ~/.aws/credentials && \
    printf "[default]\nregion=$INPUT_AWS_DEFAULT_REGION\noutput=$INPUT_AWS_DEFAULT_OUTPUT" > ~/.aws/config

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
