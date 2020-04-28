FROM alpine:3.10
MAINTAINER  <ivandreyv>

RUN apk --update add openjdk8-jre wget gnupg bash curl && rm -rf /var/cache/apk/*

ENV SOLR_USER="solr" \
    SOLR_UID="8983"  \
    SOLR_GID="8983"  \
    SOLR_GROUP="solr"\
    PATH="/opt/solr/bin:/opt/docker-solr/scripts:$PATH" \
    SOLR_INCLUDE=/etc/default/solr.in.sh \
    SOLR_HOME=/var/solr/data \
    SOLR_PID_DIR=/var/solr \
    SOLR_LOGS_DIR=/var/solr/logs \
    LOG4J_PROPS=/var/solr/log4j2.xml \
    SOLR_VERSION="8.5.0"


COPY solr-"$SOLR_VERSION".tgz /opt/

RUN set -ex; \
  addgroup --system --gid "$SOLR_GID" "$SOLR_GROUP"; \
  adduser  --system --uid "$SOLR_UID" -g "$SOLR_GROUP" "$SOLR_USER" ;\
  apk --update add openjdk8-jre wget gnupg bash curl && rm -rf /var/cache/apk/* ;\

  cd /opt; tar xzf solr-"$SOLR_VERSION".tgz && \
  ln -s solr-"$SOLR_VERSION" solr && \
  mkdir -p /opt/solr/server/solr/lib /opt/solr/server/logs && \
  chown -R "$SOLR_USER":"$SOLR_GROUP" /opt/solr/ && \
  chmod 0770 -R /opt/solr/server/logs && \
  rm -f solr-"$SOLR_VERSION".tgz ;\

  rm -Rf /opt/solr/docs/ /opt/solr/dist/{solr-core-$SOLR_VERSION.jar,solr-solrj-$SOLR_VERSION.jar,solrj-lib,solr-test-framework-$SOLR_VERSION.jar,test-framework}; \
  mkdir -p /opt/solr/server/solr/lib /docker-entrypoint-initdb.d /opt/docker-solr; \
  mkdir -p /etc/default ; \
  chown -R 0:0 "/opt/solr-$SOLR_VERSION"; \
  find "/opt/solr-$SOLR_VERSION" -type d -print0 | xargs -0 chmod 0755; \
  find "/opt/solr-$SOLR_VERSION" -type f -print0 | xargs -0 chmod 0644; \
  chmod -R 0755 "/opt/solr-$SOLR_VERSION/bin" "/opt/solr-$SOLR_VERSION/contrib/prometheus-exporter/bin/solr-exporter" /opt/solr-$SOLR_VERSION/server/scripts/cloud-scripts; \
  cp /opt/solr/bin/solr.in.sh /etc/default/solr.in.sh; \
  mv /opt/solr/bin/solr.in.sh /opt/solr/bin/solr.in.sh.orig; \
  mv /opt/solr/bin/solr.in.cmd /opt/solr/bin/solr.in.cmd.orig; \
  chown root:0 /etc/default/solr.in.sh; \
  chmod 0664 /etc/default/solr.in.sh; \
  mkdir -p /var/solr/data /var/solr/logs; \
  (cd /opt/solr/server/solr; cp solr.xml zoo.cfg /var/solr/data/); \
  cp /opt/solr/server/resources/log4j2.xml /var/solr/log4j2.xml; \
  find /var/solr -type d -print0 | xargs -0 chmod 0770; \
  find /var/solr -type f -print0 | xargs -0 chmod 0660; \
  sed -i -e "s/\"\$(whoami)\" == \"root\"/\$(id -u) == 0/" /opt/solr/bin/solr; \
  sed -i -e 's/lsof -PniTCP:/lsof -t -PniTCP:/' /opt/solr/bin/solr; \
  chown -R "0:0" /opt/solr-$SOLR_VERSION /docker-entrypoint-initdb.d /opt/docker-solr; \
  chown -R "$SOLR_USER:0" /var/solr; 

COPY --chown=0:0 scripts /opt/docker-solr/scripts

VOLUME /var/solr
EXPOSE 8983
WORKDIR /opt/solr
USER $SOLR_USER
#CMD ["/opt/solr/bin/solr", "-f"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["solr-foreground"]



