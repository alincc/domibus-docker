
FROM centos7

ARG WORKING_DIR

ARG DomibusVersion
ARG DomibusSnapshotLocation
ARG PARTY_ID
ARG DB_TYPE
ARG DB_HOST
ARG DB_PORT
ARG DB_NAME
ARG DB_USER
ARG DB_PASS

# Copying the Domibus installation Script
RUN echo '-----------------WORKING_DIR: ${WORKING_DIR}'
RUN echo '-----------------DomibusVersion: ${DomibusVersion}'
RUN echo '-----------------DomibusSnapshotLocation: ${DomibusSnapshotLocation}'

RUN mkdir -p /data/domInstall
COPY ${WORKING_DIR}/temp/domInstall /data/domInstall

# Copying the Properties Files needed for Domibus Installation Script
#  - The domInstall.properties file (MANDATORY)
#  - The Domibus property file: domibus.properties (Optional)

COPY ${WORKING_DIR}/temp/domInstall/downloads/jdbc/ /data/domibus/domibus/lib

# Changing File ownership to 'domibus' user
RUN chown -R domibus:domibus /data

# Running Domibus Installation Script (As 'domibus user')
# Next line used ONLY to force a hostname during build (Not used if IP is 0.0.0.0)
RUN su - domibus -c "/data/domInstall/install-domibus.sh"

# Copying the Domibus Startup & Run Time Configuration
COPY dockerbuild/scripts/Tomcat/entrypoint.sh /data/domibus/domibus
RUN chown domibus:domibus /data/domibus/domibus/entrypoint.sh
RUN chmod +x /data/domibus/domibus/entrypoint.sh

# Exposing Domibus
EXPOSE 8080

# Exposing Administration Console
EXPOSE 9090

ENTRYPOINT /data/domibus/domibus/entrypoint.sh

