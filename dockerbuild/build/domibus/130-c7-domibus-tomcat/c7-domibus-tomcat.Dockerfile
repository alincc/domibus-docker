FROM edelivery-tomcat-8.0.39

ENV DOMIBUS_VERSION=4.0-SNAPSHOT
ARG WORKING_DIR
ARG DOMINSTALL
ENV DOCKER_DOMINSTALL=/data/temp
ARG DOMIBUS_DISTRIBUTION
ARG DOCKER_DOMIBUS_DISTRIBUTION=/data/temp/domibus

ARG DOMIBUS_CONFIG_LOCATION=$CATALINA_HOME/conf/domibus
ENV MEMORY_SETTINGS="-Xms128m -Xmx1024m -XX:MaxPermSize=256m"
ENV CATALINA_OPTS="-Ddomibus.config.location=$DOMIBUS_CONFIG_LOCATION $MEMORY_SETTINGS"
ENV DB_TYPE="" DB_HOST="" DB_PORT="" DB_NAME="domibus" DB_USER="" DB_PASS=""

#DB_NAME cannot be passed to Domibus via properties yet



RUN rm -rf $DOCKER_DOMINSTALL
RUN mkdir -p $DOCKER_DOMINSTALL
COPY ${DOMINSTALL} $DOCKER_DOMINSTALL
COPY ${WORKING_DIR}/install-domibus.sh $DOCKER_DOMINSTALL

COPY ${DOMIBUS_DISTRIBUTION} $DOCKER_DOMIBUS_DISTRIBUTION

COPY ${WORKING_DIR}/entrypoint.sh $CATALINA_HOME
RUN chown domibus:domibus $CATALINA_HOME/entrypoint.sh
RUN chmod +x $CATALINA_HOME/entrypoint.sh

RUN chown domibus:domibus $DOCKER_DOMINSTALL/install-domibus.sh
RUN chmod +x $DOCKER_DOMINSTALL/install-domibus.sh
# Running Domibus Installation Script (As 'domibus user')
RUN su - domibus -c export CATALINA_HOME=${CATALINA_HOME} && \
    export DOMIBUS_CONFIG_LOCATION=${DOMIBUS_CONFIG_LOCATION} && \
    export DOCKER_DOMINSTALL=${DOCKER_DOMINSTALL} && \
    export DOCKER_DOMIBUS_DISTRIBUTION=${DOCKER_DOMIBUS_DISTRIBUTION} && \
    export DB_TYPE=${DB_TYPE} && \
    export DB_HOST=${DB_HOST} && \
    export DB_PORT=${DB_PORT} && \
    export DB_NAME=${DB_NAME} && \
    export DB_USER=${DB_USER} && \
    export DB_PASS=${DB_PASS} && \
    $DOCKER_DOMINSTALL/install-domibus.sh

ENTRYPOINT ["/data/tomcat/entrypoint.sh"]