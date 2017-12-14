FROM edelivery-weblogic-cluster:12.1.3

#
# Build arguments, which are environment variables accessible only during the build process.
#
ARG USER_ID
ARG DOMIBUS_PASSWORD
ARG ENV_ADMIN_PASSWORD

#
# Environment variables required for the project setup
#
ENV DB_HOST=oraclexe \
    DB_PORT=1521 \
    DOMIBUS_DIST_VERSION=3.3 \
    THIS_PARTY_NAME=blue_gw \
    THIS_PARTY_ID=domibus-blue \
    THIS_PARTY_DOMIBUS_URL=http://wlcdomibusc2_weblogic_machine1_1:7002/domibus-weblogic \
    OTHER_PARTY_NAME=red_gw \
    OTHER_PARTY_ID=domibus-red \
    OTHER_PARTY_DOMIBUS_URL=http://wlcdomibusc3_weblogic_machine1_1:7002/domibus-weblogic

#
# Add required resources
#
COPY resources/container-scripts/* ${ORACLE_HOME}/
ADD resources/wslt-api-1.9.1.zip ${ORACLE_HOME}
ADD resources/domibus-distribution-*.zip ${ORACLE_HOME}/

# Add templates
COPY resources/DOMAIN_HOME/conf/domibus/* ${DOMAIN_HOME}/conf/domibus/
COPY resources/DOMAIN_HOME/conf/domibus/plugins/config/* ${DOMAIN_HOME}/conf/domibus/plugins/config/
COPY resources/DOMAIN_HOME/conf/pmodes/* ${DOMAIN_HOME}/conf/pmodes/
COPY resources/ORACLE_HOME/wslt-api-1.9.1/* ${ORACLE_HOME}/wslt-api-1.9.1/
# Add policies
COPY resources/DOMAIN_HOME/conf/domibus/policies/* ${DOMAIN_HOME}/conf/domibus/policies/

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
    unzip ${ORACLE_HOME}/domibus-distribution-*-weblogic-configuration.zip -d ${DOMAIN_HOME}/conf/domibus && \
    unzip ${ORACLE_HOME}/domibus-distribution-*-weblogic-war.zip -d ${DOMAIN_HOME}/conf/domibus && \
    unzip ${ORACLE_HOME}/domibus-distribution-*-sample-configuration-and-testing.zip -d ${DOMAIN_HOME}/conf/domibus/samples && \
    cp ${DOMAIN_HOME}/conf/domibus/samples/conf/domibus/keystores/*jks ${DOMAIN_HOME}/conf/domibus/keystores && \
    unzip ${ORACLE_HOME}/wslt-api-1.9.1.zip -d ${ORACLE_HOME}/wslt-api-1.9.1 && \
    cp ${DOMAIN_HOME}/conf/domibus/scripts/WeblogicCluster.properties ${ORACLE_HOME}/wslt-api-1.9.1

#
# Install Domibus Plugins (WS, JMS, FS)
#
RUN if [ ! -d ${DOMAIN_HOME}/conf/domibus/plugins/lib ]; then mkdir -p ${DOMAIN_HOME}/conf/domibus/plugins/lib; fi && \
    if [ ! -d ${DOMAIN_HOME}/conf/domibus/plugins/config ]; then mkdir -p ${DOMAIN_HOME}/conf/domibus/plugins/config; fi && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-*-default-ws-plugin.zip conf/domibus/plugins/lib/domibus-default-ws-plugin-*.jar -d ${DOMAIN_HOME}/conf/domibus/plugins/lib && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-*-default-ws-plugin.zip conf/domibus/plugins/config/weblogic/ws-plugin.xml -d ${DOMAIN_HOME}/conf/domibus/plugins/config && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-*-default-jms-plugin.zip conf/domibus/plugins/lib/domibus-default-jms-plugin-*.jar -d ${DOMAIN_HOME}/conf/domibus/plugins/lib && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-*-default-jms-plugin.zip conf/domibus/plugins/config/weblogic/jms-plugin.xml -d ${DOMAIN_HOME}/conf/domibus/plugins/config && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-*-default-jms-plugin.zip conf/domibus/plugins/config/weblogic/jms-*.properties -d ${DOMAIN_HOME}/conf/domibus/plugins/config && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-*-default-fs-plugin.zip conf/domibus/plugins/lib/domibus-default-fs-plugin-*.jar -d ${DOMAIN_HOME}/conf/domibus/plugins/lib && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-*-default-fs-plugin.zip conf/domibus/plugins/config/weblogic/fs-plugin.xml -d ${DOMAIN_HOME}/conf/domibus/plugins/config && \
    unzip -j ${ORACLE_HOME}/domibus-distribution-*-default-fs-plugin.zip conf/domibus/plugins/config/weblogic/fs-plugin.properties -d ${DOMAIN_HOME}/conf/domibus/plugins/config

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
