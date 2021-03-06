FROM edelivery-wildfly:9.0.2.Final

ARG DOMIBUS_VERSION
ENV DOMIBUS_VERSION=$DOMIBUS_VERSION
ARG WORKING_DIR
ARG DOMINSTALL
ENV DOCKER_DOMINSTALL=/data/temp
ARG DOMIBUS_DISTRIBUTION
ENV DOCKER_DOMIBUS_DISTRIBUTION=/data/temp/domibus

ENV DOMIBUS_CONFIG_LOCATION=$JBOSS_HOME/conf/domibus
ENV MEMORY_SETTINGS="-Xms128m -Xmx1024m"
ENV JAVA_OPTS="-Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true -Ddomibus.config.location=$DOMIBUS_CONFIG_LOCATION $MEMORY_SETTINGS"
ENV DB_TYPE="" DB_HOST="" DB_PORT="" DB_NAME="domibus" DB_USER="" DB_PASS=""

RUN rm -rf $DOCKER_DOMINSTALL && \
    mkdir -p $DOCKER_DOMINSTALL
COPY ${DOMINSTALL} $DOCKER_DOMINSTALL
COPY ${WORKING_DIR}/install-domibus.sh $DOCKER_DOMINSTALL

COPY ${DOMIBUS_DISTRIBUTION} $DOCKER_DOMIBUS_DISTRIBUTION

COPY ${WORKING_DIR}/entrypoint.sh $JBOSS_HOME
RUN chown domibus:domibus $JBOSS_HOME/entrypoint.sh && \
 chmod +x $JBOSS_HOME/entrypoint.sh && \
 chown domibus:domibus $DOCKER_DOMINSTALL/install-domibus.sh && \
 chmod +x $DOCKER_DOMINSTALL/install-domibus.sh

# Running Domibus Installation Script (As 'domibus user')
RUN su - domibus -c export JBOSS_HOME=${JBOSS_HOME} && \
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

ENTRYPOINT ["/data/wildfly/entrypoint.sh"]

