FROM mysql:5.7

MAINTAINER CEF eDelivery <CEF-EDELIVERY-SUPPORT@ec.europa.eu>

ARG DOMIBUS_SCHEMA
ARG DOMIBUS_DATA_INIT

RUN apt-get update
RUN apt-get install unzip

COPY ${DOMIBUS_SCHEMA}  /docker-entrypoint-initdb.d
COPY ${DOMIBUS_DATA_INIT}  /docker-entrypoint-initdb.d

EXPOSE 3306

CMD ["mysqld", "--character-set-server=utf8","--collation-server=utf8_bin"]
