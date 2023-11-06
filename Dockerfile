
FROM alpine:3.18.4


ENV NGINX_VERSION 1.25.1
ENV PKG_RELEASE   1

RUN set -x \
# create nginx user/group first, to be consistent throughout docker variants
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apkArch="$(cat /etc/apk/arch)" \
    && nginxPackages=" \
        nginx=${NGINX_VERSION}-r${PKG_RELEASE} \
    " \
# install prerequisites for public key and pkg-oss checks
    && apk add --no-cache --virtual .checksum-deps \
        openssl \
    && case "$apkArch" in \
        x86_64|aarch64) \
# arches officially built by upstream
            set -x \
            && KEY_SHA512="e09fa32f0a0eab2b879ccbbc4d0e4fb9751486eedda75e35fac65802cc9faa266425edf83e261137a2f4d16281ce2c1a5f4502930fe75154723da014214f0655" \
            && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
            && if echo "$KEY_SHA512 */tmp/nginx_signing.rsa.pub" | sha512sum -c -; then \
                echo "key verification succeeded!"; \
                mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
            else \
                echo "key verification failed!"; \
                exit 1; \
            fi \
            && apk add -X "https://nginx.org/packages/mainline/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages \
            ;; \
        *) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from the published packaging sources
            set -x \
            && tempDir="$(mktemp -d)" \
            && chown nobody:nobody $tempDir \
            && apk add --no-cache --virtual .build-deps \
                gcc \
                libc-dev \
                make \
                openssl-dev \
                pcre2-dev \
                zlib-dev \
                linux-headers \
                bash \
                alpine-sdk \
                findutils \
            && su nobody -s /bin/sh -c " \
                export HOME=${tempDir} \
                && cd ${tempDir} \
                && curl -f -O https://hg.nginx.org/pkg-oss/archive/${NGINX_VERSION}-${PKG_RELEASE}.tar.gz \
                && PKGOSSCHECKSUM=\"dd08a5c2b441817d58ffc91ade0d927a21bc9854c768391e92a005997a2961bcda64ca6a5cfce98d5394ac2787c8f4839b150f206835a8a7db944625651f9fd8 *${NGINX_VERSION}-${PKG_RELEASE}.tar.gz\" \
                && if [ \"\$(openssl sha512 -r ${NGINX_VERSION}-${PKG_RELEASE}.tar.gz)\" = \"\$PKGOSSCHECKSUM\" ]; then \
                    echo \"pkg-oss tarball checksum verification succeeded!\"; \
                else \
                    echo \"pkg-oss tarball checksum verification failed!\"; \
                    exit 1; \
                fi \
                && tar xzvf ${NGINX_VERSION}-${PKG_RELEASE}.tar.gz \
                && cd pkg-oss-${NGINX_VERSION}-${PKG_RELEASE} \
                && cd alpine \
                && make base \
                && apk index -o ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz ${tempDir}/packages/alpine/${apkArch}/*.apk \
                && abuild-sign -k ${tempDir}/.abuild/abuild-key.rsa ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz \
                " \
            && cp ${tempDir}/.abuild/abuild-key.rsa.pub /etc/apk/keys/ \
            && apk del --no-network .build-deps \
            && apk add -X ${tempDir}/packages/alpine/ --no-cache $nginxPackages \
            ;; \
    esac \
# remove checksum deps
    && apk del --no-network .checksum-deps \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
    && if [ -n "/etc/apk/keys/abuild-key.rsa.pub" ]; then rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
    && if [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ]; then rm -f /etc/apk/keys/nginx_signing.rsa.pub; fi \
# Bring in gettext so we can get `envsubst`, then throw
# the rest away. To do this, we need to install `gettext`
# then move `envsubst` out of the way so `gettext` can
# be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del --no-network .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
# Bring in tzdata so users could set the timezones through the environment
# variables
    && apk add --no-cache tzdata \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
# create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d

	
#create pfe user and gib rights to directory 
RUN adduser -u 5000 pfe  --disabled-password 
	
	
COPY  docker-entrypoint.sh /
COPY  10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY  15-local-resolvers.envsh /docker-entrypoint.d
COPY  20-envsubst-on-templates.sh /docker-entrypoint.d
COPY  30-tune-worker-processes.sh /docker-entrypoint.d	

RUN chmod -R 700 /docker-entrypoint.d
RUN chmod 700 docker-entrypoint.sh

RUN mkdir -p /var/run/nginx /var/tmp/nginx  \
	&& touch /var/run/nginx.pid \
	&& rm -f /etc/nginx/conf.d/default.conf \
	&& chown -R pfe:pfe 	/opt /etc/nginx /docker-entrypoint.sh /usr/share/nginx/  /var/tmp/nginx/ /var/log/nginx  /docker-entrypoint.d /var/cache/nginx /var/run/nginx.pid \
	&& rm -rf /bin/arch /bin/cat /bin/echo /bin/dd /bin/df /bin/egrep /bin/grep /bin/gunzip /bin/gzip /bin/hostname /bin/mkdir /bin/more  /bin/mount /bin/mountpoint /bin/mpstat /bin/netstat \
			  /bin/ping /bin/printenv /bin/ps /bin/pwd /bin/rmdir /bin/stat /bin/tar /bin/umount /bin/uname /bin/watch /bin/zcat \
	&& rm -rf /sbin/apk /sbin/fdisk /sbin/fsck \
	&& rm -rf /usr/bin/awk /usr/bin/bunzip2 /usr/bin/bzcat /usr/bin/bzip2 /usr/bin/clear /usr/bin/cut /usr/bin/dc /usr/bin/dirname /usr/bin/diff /usr/bin/du /usr/bin/find /usr/bin/free \
			  /usr/bin/head /usr/bin/nc /usr/bin/nl /usr/bin/pgrep /usr/bin/pkill /usr/bin/tee /usr/bin/tail /usr/bin/top /usr/bin/tr /usr/bin/unzip /usr/bin/uptime /usr/bin/vi /usr/bin/wc \
			  /usr/bin/wget /usr/bin/which /usr/bin/who /usr/bin/whois
	
COPY nginx.conf /etc/nginx/nginx.conf 
ENTRYPOINT ["/docker-entrypoint.sh"]


USER pfe
EXPOSE 80 443

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]


