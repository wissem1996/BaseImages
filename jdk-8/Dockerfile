
FROM alpine:3.18.4 
	
# Set the WILDFLY_VERSION env variable
ENV BACKEND_HOME /opt/backend
ENV PFE_HOME /opt/users/pfe
ENV PATH $BACKEND_HOME/bin:$PATH




WORKDIR  $BACKEND_HOME
# Make sure the distribution is available from a well-known place

	## Adding user pfe 

RUN apk update --no-cache \
    && apk add openjdk8-jre --no-cache \
    && apk upgrade libssl3 libcrypto3 --no-cache \
    ## Fixing the  libcrypto3/libssl3 CVE-2023-2650 vulnerability
    && addgroup -S pfe  \
    && mkdir -p $PFE_HOME/bin \
    && adduser -D -S -h $PFE_HOME -s $PFE_HOME/bin/bash -G pfe pfe  \
    && ln -s /bin/ls  $PFE_HOME/bin/ls  \
    && ln -s /usr/bin/tail  $PFE_HOME/bin/tail  \
    && ln -s /usr/bin/cut  $PFE_HOME/bin/cut  \
    && ln -s /bin/uname  $PFE_HOME/bin/uname  \
    && ln -s /bin/mv  $PFE_HOME/bin/mv  \
    && ln -s /bin/cp  $PFE_HOME/bin/cp  \
    && ln -s /bin/grep  $PFE_HOME/bin/grep  \
    && ln -s /usr/bin/dirname  $PFE_HOME/bin/dirname  \
    && ln -s /usr/bin/basename $PFE_HOME/bin/basename  \
    && ln -s /usr/bin/env  $PFE_HOME/bin/env  \
    && ln -s /usr/bin/envsubst  $PFE_HOME/bin/envsubst  \
    && ln -s /usr/bin/tr  $PFE_HOME/bin/tr  \
    && ln -s /usr/lib/jvm/java-1.8-openjdk/jre/bin/java  $PFE_HOME/bin/java \
    && ln -s /bin/bash  $PFE_HOME/bin/bash \
    && echo 'export ENV=~/.profile' >> /etc/profile \
    && echo "export PATH=$PFE_HOME/bin" > $PFE_HOME/.profile \
    && echo "export PATH=$PFE_HOME/bin" > $PFE_HOME/.bashrc \
    && chown -R pfe: /opt/  \
    && chmod -R 755 /opt/* \
    && chown root: $PFE_HOME/.bashrc  $PFE_HOME/.profile \
# DISABLE ROOT ACCESS 
    && sed -e '/root/ s/^#*/#/' -i /etc/passwd
	
#delete unnecessary exec
RUN rm -rf  /bin/cat  /bin/dd /bin/df  /bin/gunzip /bin/gzip  /bin/more  /bin/mount /bin/mountpoint /bin/mpstat /bin/netstat \
			  /bin/ping /bin/printenv /bin/ps /bin/pwd /bin/rmdir /bin/stat /bin/tar /bin/umount  /bin/watch /bin/zcat \
	&& rm -rf /sbin/apk /sbin/fdisk /sbin/fsck \
	&& rm -rf /usr/bin/awk /usr/bin/bunzip2 /usr/bin/bzcat /usr/bin/bzip2 /usr/bin/clear /usr/bin/cut /usr/bin/dc  /usr/bin/diff /usr/bin/du /usr/bin/find /usr/bin/free \
			  /usr/bin/head /usr/bin/nc /usr/bin/nl /usr/bin/pgrep /usr/bin/pkill /usr/bin/tee  /usr/bin/top  /usr/bin/unzip /usr/bin/uptime /usr/bin/vi /usr/bin/wc \
			  /usr/bin/wget /usr/bin/which /usr/bin/who /usr/bin/whoami  /usr/bin/whois

	
	
RUN chmod 700 /tmp /opt/users/pfe/  \
	&& chmod 640 ${PFE_HOME}/.bashrc /opt/users/pfe/.profile \
	&& chmod 700   /etc/hostname   \
	&& sed -e '/root/ s/^#*/#/' -i /etc/passwd \
	&& chmod 640 ${PFE_HOME}/.bashrc /opt/users/pfe/.profile 

# change owner /tmp to avoid permission denied java.io 	
RUN chown pfe:pfe -R /tmp
	
COPY --chown=pfe:pfe ./jdk-8/entrypoint.sh /opt/backend/entrypoint.sh

RUN chmod 777 /opt/backend/entrypoint.sh

EXPOSE 8080
USER pfe

ENTRYPOINT ["/opt/backend/entrypoint.sh"]
	




