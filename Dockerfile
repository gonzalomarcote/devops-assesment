# Litecoin 0.18.1
FROM debian:bullseye-slim
LABEL maintainer="Gonzalo Marcote <gonzalomarcote@gmail.com>"
LABEL version="0.18.1"

# Define some needed variables
ENV LITECOIN_VERSION=0.18.1
ENV LITECOIN_DATA=/home/litecoin/.litecoin

# Create litecoin user
RUN groupadd -r litecoin && useradd --no-log-init -r -g litecoin litecoin

# Install required packages
RUN set -ex \
	&& apt-get -qq update \
	&& apt-get -qq -y install gosu gnupg curl software-properties-common

# Update glibc package from testing due High CVE-2021-33574 vulnerability
RUN add-apt-repository "deb http://httpredir.debian.org/debian testing main" \
    && apt-get -qq update \
    && apt-get -qq -t testing -y install --no-install-recommends libc6 libc6-dev libc6-dbg

# Clean apt cache packages to make image lighter
RUN apt-get clean \
    && rm -rf /var/lib/apt \
    && rm -rf /var/lib/dpkg

# Download litecoin package
RUN curl -s -o litecoin.tar.gz https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz

# Compare checksum (if don't match, build crash)
RUN SUM=$(curl -s -i https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-linux-signatures.asc | grep litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz | awk '{print $1}') && echo "${SUM} litecoin.tar.gz" | sha256sum -c -

# Uncompress litecoin
RUN tar --strip=2 -xzf litecoin.tar.gz -C /usr/local/bin
RUN rm *.tar.gz

# Entrypoint
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Expose ports and run litcoin daemon
EXPOSE 9332 9333 19332 19333 19444
ENTRYPOINT ["/entrypoint.sh"]
CMD ["litecoind"]
