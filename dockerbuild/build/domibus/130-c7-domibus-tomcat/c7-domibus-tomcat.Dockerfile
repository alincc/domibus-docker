FROM edelivery-tomcat-8.0.39

ENV DOMIBUS_VERSION=4.0-SNAPSHOT
ARG WORKING_DIR
ARG DOMINSTALL
ARG DOCKER_DOMINSTALL=/data/temp/domInstall
ARG DOMIBUS_DISTRIBUTION
ARG DOCKER_DOMIBUS_DISTRIBUTION=/data/temp/domibus

ARG DOMIBUS_CONFIG_LOCATION=$CATALINA_HOME/conf/domibus
ENV MEMORY_SETTINGS="-Xms128m -Xmx1024m -XX:MaxPermSize=256m"
ENV CATALINA_OPTS="-Ddomibus.config.location=$DOMIBUS_CONFIG_LOCATION $MEMORY_SETTINGS"
ENV DB_TYPE="" DB_HOST="" DB_PORT="" DB_NAME="" DB_USER="" DB_PASS=""

RUN rm -rf $DOCKER_DOMINSTALL
RUN mkdir -p $DOCKER_DOMINSTALL
COPY ${DOMINSTALL} $DOCKER_DOMINSTALL
COPY ${WORKING_DIR}/install-domibus.sh $DOCKER_DOMINSTALL

COPY ${DOMIBUS_DISTRIBUTION} $DOCKER_DOMIBUS_DISTRIBUTION

RUN chown domibus:domibus $DOCKER_DOMINSTALL/install-domibus.sh
RUN chmod +x $DOCKER_DOMINSTALL/install-domibus.sh
# Running Domibus Installation Script (As 'domibus user')
RUN su - domibus -c "$DOCKER_DOMINSTALL/install-domibus.sh ${CATALINA_HOME} ${DOMIBUS_CONFIG_LOCATION} ${DOCKER_DOMINSTALL} ${DOCKER_DOMIBUS_DISTRIBUTION} ${DB_TYPE} ${DB_HOST} ${DB_PORT} ${DB_NAME} ${DB_USER} ${DB_PASS} 4.0-SNAPSHOT"
