FROM edelivery-centos

ENV CATALINA_HOME=/data/tomcat

ARG WORKING_DIR=.
ARG JDBC_DRIVER_DIR
ARG DOM_INSTALL=/data/domInstall

RUN mkdir -p $DOM_INSTALL
COPY ${WORKING_DIR}/temp/domInstall $DOM_INSTALL
COPY ${JDBC_DRIVER_DIR}/ $DOM_INSTALL/jdbcDrivers

COPY ${WORKING_DIR}/install-domibus.sh $DOM_INSTALL

# Changing File ownership to 'domibus' user
RUN chown -R domibus:domibus /data
RUN chown domibus:domibus $DOM_INSTALL/install-domibus.sh
RUN chmod +x $DOM_INSTALL/install-domibus.sh

# Running Domibus Installation Script (As 'domibus user')
RUN su - domibus -c "$DOM_INSTALL/install-domibus.sh ${CATALINA_HOME} ${DOM_INSTALL} $DOM_INSTALL/jdbcDrivers"

# Copying the Domibus Startup & Run Time Configuration
COPY ${WORKING_DIR}/entrypoint.sh $CATALINA_HOME
RUN chown domibus:domibus $CATALINA_HOME/entrypoint.sh
RUN chmod +x $CATALINA_HOME/entrypoint.sh

# Exposing Domibus
EXPOSE 8080

# Exposing JaCoCo port
EXPOSE 6400

ENTRYPOINT ["/data/tomcat/entrypoint.sh"]

