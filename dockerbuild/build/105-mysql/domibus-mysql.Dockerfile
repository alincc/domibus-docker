
FROM mysql:5.7

MAINTAINER CEF eDelivery <CEF-EDELIVERY-SUPPORT@ec.europa.eu>

RUN apt-get update
RUN apt-get install unzip

COPY ./temp/sql-scripts/*.sql  /docker-entrypoint-initdb.d

EXPOSE 3306
