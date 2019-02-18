FROM oraclelinux:7-slim

# set some environment variables defaults to be used in the image setup
ARG ORACLE_SYS_PASSWORD
ARG DOMIBUS_PASSWORD
ARG DOMIBUS_VERSION
ARG DOMIBUS_SHORT_VERSION

ENV TZ=Europe/Brussels

RUN apt-get install unzip

# add sql scripts to the directory /docker-entrypoint-initdb.d which are executed on the oracle xe db
# during the container startup

# sql script which changes the administrative accounts credentials based on the variable ORACLE_SYS_PASSWORD
ADD resources/setup_oracle.sql /docker-entrypoint-initdb.d/
# sql script which creates domibus user schema and gives it the correct permissions
ADD resources/init_domibus_schema.sql /docker-entrypoint-initdb.d/
# sql script which initializes domibus schema data structure
ADD resources/domibus-distribution-${DOMIBUS_VERSION}-sql-scripts.zip /docker-entrypoint-initdb.d/
RUN unzip -j /docker-entrypoint-initdb.d/domibus-distribution-${DOMIBUS_VERSION}-sql-scripts.zip sql-scripts/oracle10g-${DOMIBUS_SHORT_VERSION}.ddl -d /docker-entrypoint-initdb.d/
RUN unzip -j /docker-entrypoint-initdb.d/domibus-distribution-${DOMIBUS_VERSION}-sql-scripts.zip sql-scripts/oracle10g-${DOMIBUS_SHORT_VERSION}-data.ddl -d /docker-entrypoint-initdb.d/

# apply the environment variables values to the sql scripts
RUN sed -i "s/ORACLE_SYS_PASSWORD/${ORACLE_SYS_PASSWORD}/g" /docker-entrypoint-initdb.d/setup_oracle.sql && \
    sed -i "s/DOMIBUS_PASSWORD/${DOMIBUS_PASSWORD}/g" /docker-entrypoint-initdb.d/init_domibus_schema.sql && \
    sed -i "s/DOMIBUS_SHORT_VERSION/${DOMIBUS_SHORT_VERSION}/g" /docker-entrypoint-initdb.d/init_domibus_schema.sql && \
# configure the correct timezone
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone
