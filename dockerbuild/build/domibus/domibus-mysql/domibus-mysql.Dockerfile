FROM mysql:5.7

MAINTAINER CEF eDelivery <CEF-EDELIVERY-SUPPORT@ec.europa.eu>

ARG DOMIBUS_SCHEMA

RUN apt-get update
RUN apt-get install unzip

COPY ${DOMIBUS_SCHEMA}  /docker-entrypoint-initdb.d

EXPOSE 3306
