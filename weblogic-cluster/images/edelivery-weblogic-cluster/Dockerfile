FROM oraclelinux:7-slim

#
# Build arguments, which are environment variables accessible only during the build process.
#
ARG USER_ID
ARG PRODUCTION_MODE
ARG ADMIN_PASSWORD
ARG FMW_PKG=fmw_12.1.3.0.0_wls.jar

#
# Environment variables required for the project setup
#
ENV JAVA_HOME=/usr/java/default \
    ORACLE_HOME=/u01/oracle \
    DOMAIN_NAME="base_domain" \
    DOMAIN_HOME="/u01/oracle/user_projects/domains/base_domain" \
    USER_MEM_ARGS="-Djava.security.egd=file:/dev/./urandom -Ddomibus.config.location=/u01/oracle/user_projects/domains/base_domain/conf/domibus -Xms1024m -Xmx1024m" \
    ADMIN_PORT="7001" \
    ADMIN_HOST="wlsadmin" \
    ADMIN_USERNAME=weblogic \
    ADMIN_PASSWORD=${ADMIN_PASSWORD} \
    CLUSTER_NAME=EDeliveryCluster \
    CLUSTER_SERVERS=2 \
    NM_PORT="5556" \
    MS_PORT="7002" \
    PRODUCTION_MODE="${PRODUCTION_MODE:-prod}" \
    CONFIG_JVM_ARGS="-Dweblogic.security.SSL.ignoreHostnameVerification=true" \
    WL_HOME="/u01/oracle/wlserver" \
    TZ=Europe/Brussels \
    PATH=$PATH:/usr/java/default/bin:/u01/oracle/oracle_common/common/bin:/u01/oracle/wlserver/common/bin:/u01/oracle/user_projects/domains/base_domain/bin:/u01/oracle

#
# Install required packages and cleanup
#
RUN yum -y install unzip vim telnet && \
    yum clean all && rm -rf /var/cache/yum

#
# Setup Oracle environment
#
RUN mkdir -p /u01 && \
    chmod a+xr /u01 && \
    useradd -b /u01 -d /u01/oracle -m -u $USER_ID -s /bin/bash oracle

#
# Add required resources
#
ADD resources/jdk-8u144-linux-x64.tar.gz /usr/java/
ADD resources/dockerize-linux-amd64-v0.6.0.tar.gz /usr/local/bin
COPY resources/$FMW_PKG resources/install.file resources/oraInst.loc /u01/
COPY resources/container-scripts/* ${ORACLE_HOME}/

RUN export JAVA_DIR=$(ls -1 -d /usr/java/*) && \
    ln -s $JAVA_DIR /usr/java/latest && \
    ln -s $JAVA_DIR /usr/java/default && \
    alternatives --install /usr/bin/java java $JAVA_DIR/bin/java 20000 && \
    alternatives --install /usr/bin/javac javac $JAVA_DIR/bin/javac 20000 && \
    alternatives --install /usr/bin/jar jar $JAVA_DIR/bin/jar 20000 && \
    chown oracle:oracle -R /u01 && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

#
# Install WebLogic Server
#
USER oracle
RUN $JAVA_HOME/bin/java -jar /u01/$FMW_PKG -ignoreSysPrereqs -novalidation -silent -responseFile /u01/install.file -invPtrLoc /u01/oraInst.loc -jreLoc $JAVA_HOME ORACLE_HOME=$ORACLE_HOME INSTALL_TYPE="WebLogic Server" && \
    rm /u01/$FMW_PKG /u01/oraInst.loc /u01/install.file

#
# Configuration of WebLogic Server Domain
#
WORKDIR /u01/oracle
RUN chmod +x *.sh && \
    /u01/oracle/wlst /u01/oracle/create-wls-domain.py && \
    mkdir -p ${DOMAIN_HOME}/servers/AdminServer/security && \
    echo "username=${ADMIN_USERNAME}" > ${DOMAIN_HOME}/servers/AdminServer/security/boot.properties && \
    echo "password=${ADMIN_PASSWORD}" >> ${DOMAIN_HOME}/servers/AdminServer/security/boot.properties && \
    echo ". ${DOMAIN_HOME}/bin/setDomainEnv.sh" >> /u01/oracle/.bashrc && \
    echo "export PATH=$PATH:/u01/oracle/wlserver/common/bin:${DOMAIN_HOME}/bin" >> /u01/oracle/.bashrc && \
    cp /u01/oracle/commEnv.sh /u01/oracle/wlserver/common/bin/commEnv.sh && \
    rm /u01/oracle/create-wls-domain.py /u01/oracle/jaxrs2-template.jar

#
# Expose Node Manager default port, and also default http/https ports for admin console
#
EXPOSE $NM_PORT $ADMIN_PORT $MS_PORT

#
# Define default command
#
WORKDIR $DOMAIN_HOME
CMD ["startWebLogic.sh"]
