
FROM centos7

ARG WORKING_DIR
ARG DOMINSTALL_PROPERTYFILE

ARG PARTY_ID
ARG DB_TYPE
ARG DB_HOST
ARG DB_PORT
ARG DB_NAME
ARG DB_USER
ARG DB_PASS

# Copying the Domibus installation Script
RUN mkdir -p /data/domInstall
COPY ${WORKING_DIR}/temp/domInstall /data/domInstall

# Copying the Properties Files needed for Domibus Installation Script
#  - The domInstall.properties file (MANDATORY)
#  - The Domibus property file: domibus.properties (Optional)
COPY ${WORKING_DIR}/${DOMINSTALL_PROPERTYFILE} /data/domInstall/

# Changing File ownership to 'domibus' user
RUN chown -R domibus:domibus /data

# Running Domibus Installation Script (As 'domibus user')
RUN su - domibus -c "/data/domInstall/install-domibus.sh /data/domInstall/${DOMINSTALL_PROPERTYFILE}"

# Copying the Domibus Startup & Run Time Configuration
COPY dockerbuild/scripts/WildFly/entrypoint_Oracle.sh /data/domibus/domibus
RUN chown domibus:domibus /data/domibus/domibus/entrypoint_Oracle.sh
RUN chmod +x /data/domibus/domibus/entrypoint_Oracle.sh

# Exposing Domibus
EXPOSE 8080

# Exposing WildFly Administration Console
EXPOSE 9090

ENTRYPOINT /data/domibus/domibus/entrypoint_Oracle.sh

