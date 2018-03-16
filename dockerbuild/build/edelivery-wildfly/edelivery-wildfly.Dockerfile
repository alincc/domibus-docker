FROM edelivery-centos

ENV WILDFLY_VERSION=9.0.2.Final
ENV JBOSS_HOME=/data/wildfly
ENV ADMIN_USER=admin ADMIN_PASSWORD=admin1

ARG JDBC_DRIVER_DIR
ARG WORKING_DIR=.
ARG DOM_INSTALL=/data/domInstall
ENV WILDFLY_ARCHIVE_DIR=$DOM_INSTALL/wildfly

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# Copying the Domibus installation Script
RUN mkdir -p $DOM_INSTALL
COPY ${WORKING_DIR}/temp/domInstall $DOM_INSTALL

COPY ${JDBC_DRIVER_DIR}/ $DOM_INSTALL/jdbcDrivers
COPY ${WORKING_DIR}/install-wildfly.sh $DOM_INSTALL

USER root

RUN cd $WILDFLY_ARCHIVE_DIR \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R domibus:domibus ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

RUN ${JBOSS_HOME}/bin/add-user.sh $ADMIN_USER $ADMIN_PASSWORD --silent

# Running Domibus Installation Script (As 'domibus user')
RUN $DOM_INSTALL/install-wildfly.sh ${JBOSS_HOME} ${DOM_INSTALL} $DOM_INSTALL/jdbcDrivers

#USER domibus

# Exposing WildFly Administration Console
EXPOSE 9990

# Exposing http port
EXPOSE 8080

# Exposing JaCoCo port
EXPOSE 6400

RUN rm -rf /data/wildfly/standalone/configuration/standalone_xml_history/current

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/data/wildfly/bin/standalone.sh", "--server-config=standalone-full.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

