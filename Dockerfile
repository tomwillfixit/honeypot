FROM ubuntu:17.10

RUN apt-get update && apt-get install gcc rsyslog wget make -y

ENV OPENSSH=/opt/openssh2

RUN mkdir -p ${OPENSSH}

WORKDIR ${OPENSSH}

# Build zlib

RUN wget http://zlib.net/zlib-1.2.11.tar.gz && \
    tar xvfz zlib-1.2.11.tar.gz && \
    cd zlib-1.2.11 && \
    ./configure --prefix=${OPENSSH}/dist/ && make && make install

# Build openssl

RUN wget http://www.openssl.org/source/openssl-1.0.1e.tar.gz && \
    tar xvfz openssl-1.0.1e.tar.gz && \
    cd openssl-1.0.1e && \
    ./config --prefix=${OPENSSH}/dist/ && make && make install

# Build openssh

RUN wget https://ftp.eu.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.2p1.tar.gz && \
    tar xvfz openssh-6.2p1.tar.gz

COPY auth-passwd.c ${OPENSSH}/openssh-6.2p1/auth-passwd.c

RUN cd openssh-6.2p1 && \
    useradd sshd && \
    ./configure --prefix=${OPENSSH}/dist/ --with-zlib=${OPENSSH}/dist --with-ssl-dir=${OPENSSH}/dist/ && make && make install 

# Copy in sshd_config with syslog logging enabled and then the container is ready

COPY sshd_config ${OPENSSH}/dist/etc/sshd_config

# Copy in script with starts rsyslog and sshd
COPY start_honeypot.sh /tmp/start_honeypot.sh 

# Create auth.log and change ownership 
RUN touch /var/log/auth.log
RUN chown syslog:adm /var/log/auth.log

ENTRYPOINT /tmp/start_honeypot.sh 
