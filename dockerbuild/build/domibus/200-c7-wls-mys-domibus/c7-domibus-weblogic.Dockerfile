
FROM centos7-weblogic

ARG JAVA_VERSION
ARG WORKING_DIR
ARG DOMINSTALL_PROPERTYFILE
ARG PARTY_ID
ARG DB_TYPE
ARG DB_HOST
ARG DB_PORT
ARG DB_NAME
ARG DB_USER
ARG DB_PASS

ENV JAVA_HOME=/usr/local/java/jdk1.7.0_80
ENV PATH=$JAVA_HOME/bin:$PATH

# Copying the Domibus installation Script
RUN mkdir -p /data/domInstall
COPY  ${WORKING_DIR}/temp/domInstall /data/domInstall

# Copying the Properties Files needed for Domibus Installation Script
#  - The domInstall.properties file (MANDATORY)
#  - The Domibus property file: domibus.properties (Optional)
COPY ${WORKING_DIR}/${DOMINSTALL_PROPERTYFILE} /data/domInstall/

# Changing File ownership to 'domibus' user
RUN chown -R domibus:domibus /data

# Running Domibus Installation Script (As 'domibus user')
# Next line used ONLY to force a hostname during build (Not used if IP is 0.0.0.0)
RUN su - domibus -c "/data/domInstall/install-domibus.sh /data/domInstall/${DOMINSTALL_PROPERTYFILE}"

# Copying the Domibus Startup & Run Time Configuration
COPY dockerbuild/scripts/WebLogic/entrypoint.sh /data/domibus
RUN chown domibus:domibus /data/domibus/entrypoint.sh
RUN chmod +x /data/domibus/entrypoint.sh

# Exposing WebLogic Management Console (Admin Server)
EXPOSE 7001

# Exposing Weblogic Managed Server
EXPOSE 7003

ENTRYPOINT /data/domibus/entrypoint.sh

