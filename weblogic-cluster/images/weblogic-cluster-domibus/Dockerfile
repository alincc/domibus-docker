FROM edelivery-weblogic-cluster:12.1.3

#
# Build arguments, which are environment variables accessible only during the build process.
#
ARG USER_ID
ARG DOMIBUS_PASSWORD
ARG ADMIN_PASSWORD
ARG DOMIBUS_VERSION

#
# Environment variables required for the project setup
#
ENV DB_HOST=oraclexe \
    DB_PORT=1521 \
    DOMIBUS_VERSION=${DOMIBUS_VERSION}

#
# Add required resources
#
COPY resources/container-scripts/* ${ORACLE_HOME}/
ADD resources/wslt-api-1.9.1.zip ${ORACLE_HOME}
ADD resources/domibus-distribution-${DOMIBUS_VERSION}-*.zip ${ORACLE_HOME}/

#
# Setup Oracle environment
#
USER root
RUN chown oracle:oracle -R /u01

#
# Configuration of WebLogic Server Domain
#
WORKDIR /u01/oracle
RUN chmod +x *.sh && \
    /u01/oracle/wlst /u01/oracle/enable-protected-jmx-access.py

USER oracle

#
# Install Domibus Resources
#
RUN mkdir -p ${DOMAIN_HOME}/conf/domibus/keystores && \
    unzip ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-weblogic-configuration.zip -d ${DOMAIN_HOME}/conf/domibus && \
    unzip ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-weblogic-war.zip -d ${DOMAIN_HOME}/conf/domibus && \
    unzip ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-sample-configuration-and-testing.zip -d ${DOMAIN_HOME}/conf/domibus/samples && \
    cp ${DOMAIN_HOME}/conf/domibus/samples/conf/domibus/keystores/*jks ${DOMAIN_HOME}/conf/domibus/keystores && \
    unzip ${ORACLE_HOME}/wslt-api-1.9.1.zip -d ${ORACLE_HOME}/wslt-api-1.9.1

#
# Install Domibus Plugins (WS, JMS, FS)
#
RUN if [ ! -d ${DOMAIN_HOME}/conf/domibus/plugins/lib ]; then mkdir -p ${DOMAIN_HOME}/conf/domibus/plugins/lib; fi && \
    if [ ! -d ${DOMAIN_HOME}/conf/domibus/plugins/config ]; then mkdir -p ${DOMAIN_HOME}/conf/domibus/plugins/config; fi && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/lib/domibus-default-ws-plugin-*.jar -d ${DOMAIN_HOME}/conf/domibus/plugins/lib && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/config/weblogic/ws-plugin.xml -d ${DOMAIN_HOME}/conf/domibus/plugins/config

RUN unzip -j ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-default-jms-plugin.zip conf/domibus/plugins/lib/domibus-default-jms-plugin-*.jar -d ${DOMAIN_HOME}/conf/domibus/plugins/lib && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-default-jms-plugin.zip conf/domibus/plugins/config/weblogic/jms-plugin.xml -d ${DOMAIN_HOME}/conf/domibus/plugins/config && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-default-jms-plugin.zip conf/domibus/plugins/config/weblogic/jms-*.properties -d ${DOMAIN_HOME}/conf/domibus/plugins/config

RUN unzip -j ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-default-fs-plugin.zip conf/domibus/plugins/lib/domibus-default-fs-plugin-*.jar -d ${DOMAIN_HOME}/conf/domibus/plugins/lib && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-default-fs-plugin.zip conf/domibus/plugins/config/weblogic/fs-plugin.xml -d ${DOMAIN_HOME}/conf/domibus/plugins/config && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-${DOMIBUS_VERSION}-default-fs-plugin.zip conf/domibus/plugins/config/weblogic/fs-plugin.properties -d ${DOMAIN_HOME}/conf/domibus/plugins/config

#
# Logback update to allow configuration changes to be aplied without Weblogic restart
#
RUN sed -i "s/^<configuration>/<configuration scan=\"true\" scanPeriod=\"30 seconds\">/g" ${DOMAIN_HOME}/conf/domibus/logback.xml

#
# Expose Node Manager default port, and also default http/https ports for admin console
#
EXPOSE $NM_PORT $ADMIN_PORT $MS_PORT

#
# Define default command
#
WORKDIR $DOMAIN_HOME
CMD ["startWebLogicEntrypoint.sh"]
