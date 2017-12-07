FROM edelivery-tomcat-8.0.39

ARG WORKING_DIR
ARG DomibusSnapshotLocation

# Copying the Domibus installation Script
RUN echo '-----------------JAVA_HOME: ${JAVA_HOME}'
RUN echo '-----------------WORKING_DIR: ${WORKING_DIR}'
RUN echo '-----------------DomibusSnapshotLocation: ${DomibusSnapshotLocation}'

RUN mkdir -p /data/domInstall
COPY ${WORKING_DIR}/temp/domInstall /data/domInstall
COPY ${WORKING_DIR}/install-domibus.sh /data/domInstall


RUN chown domibus:domibus /data/domInstall/install-domibus.sh
RUN chmod +x /data/domInstall/install-domibus.sh
# Running Domibus Installation Script (As 'domibus user')
RUN su - domibus -c "/data/domInstall/install-domibus.sh"

# Copying the Domibus Startup & Run Time Configuration
COPY ${WORKING_DIR}/entrypoint.sh /data/domibus/domibus
RUN chown domibus:domibus /data/domibus/domibus/entrypoint.sh
RUN chmod +x /data/domibus/domibus/entrypoint.sh

ENTRYPOINT /data/domibus/domibus/entrypoint.sh

