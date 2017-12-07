FROM edelivery-tomcat-8.0.39

ARG WORKING_DIR
ARG DOMINSTALL
ARG DOCKER_DOMINSTALL=/data/temp/domInstall
ARG DOMIBUS_DISTRIBUTION
ARG DOCKER_DOMIBUS_DISTRIBUTION=/data/temp/domibus

ARG DOMIBUS_CONFIG_LOCATION=$CATALINA_HOME/conf/domibus
ENV CATALINA_OPTS="-Ddomibus.config.location=$DOMIBUS_CONFIG_LOCATION"

ENV DB_TYPE=""
ENV DB_HOST=""
ENV DB_PORT=""
ENV DB_NAME=""
ENV DB_USER=""
ENV DB_PASS=""


# Copying the Domibus installation Script
RUN echo '-----------------DOMIBUS_CONFIG_LOCATION: ${DOMIBUS_CONFIG_LOCATION}'
RUN echo '-----------------CATALINA_OPTS: ${CATALINA_OPTS}'
RUN echo '-----------------CATALINA_HOME: ${CATALINA_HOME}'
RUN echo '-----------------DOMINSTALL: ${DOMINSTALL}'
RUN echo '-----------------LOCAL_DOMIBUS_DISTRIBUTION: ${LOCAL_DOMIBUS_DISTRIBUTION}'
RUN echo '-----------------WORKING_DIR: ${WORKING_DIR}'
RUN echo '-----------------DB_TYPE: ${DB_TYPE}'
RUN echo '-----------------DB_HOST: ${DB_HOST}'
RUN echo '-----------------DB_PORT: ${DB_PORT}'
RUN echo '-----------------DB_NAME: ${DB_NAME}'
RUN echo '-----------------DB_USER: ${DB_USER}'
RUN echo '-----------------DB_PASS: ${DB_PASS}'

#RUN mkdir -p $DOMIBUS_CONFIG_LOCATION

RUN rm -rf $DOCKER_DOMINSTALL
RUN mkdir -p $DOCKER_DOMINSTALL
COPY ${DOMINSTALL} $DOCKER_DOMINSTALL
COPY ${WORKING_DIR}/install-domibus.sh $DOCKER_DOMINSTALL

COPY ${DOMIBUS_DISTRIBUTION} $DOCKER_DOMIBUS_DISTRIBUTION

RUN chown domibus:domibus $DOCKER_DOMINSTALL/install-domibus.sh
RUN chmod +x $DOCKER_DOMINSTALL/install-domibus.sh
# Running Domibus Installation Script (As 'domibus user')
RUN su - domibus -c "$DOCKER_DOMINSTALL/install-domibus.sh"
