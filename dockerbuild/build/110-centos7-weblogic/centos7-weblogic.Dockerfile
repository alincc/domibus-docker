
FROM centos7

RUN mkdir -p /data/WebLogic
#RUN wget -P /data/WebLogic https://ec.europa.eu/cefdigital/code/projects/EDELIVERY/repos/docker/browse/dockerbuild/REPO/Oracle/fmw_12.1.3.0.0_wls.jar

# JAVA JDK(s) Installation
COPY temp/java /usr/local/java
RUN \
for file in `ls -1 /usr/local/java | grep jdk` ; \
   do				\
      cd /usr/local/java ;	\
      tar xvfz ${file}		\
      && rm ${file} ;		\
   done

# WebLogic & Unattended Setup files
COPY	temp/fmw_12.1.3.0.0_wls.jar	\
	install_weblogic.sh		\
	wls_answer_file			\
	oraInst.loc			\
	temp/wslt-api-1.9.1.zip \
	/data/WebLogic/

# Adding user 'wls' for WebLogic
#RUN useradd wls

RUN mkdir /data/WebLogic/oraInventory && chown -R domibus:domibus /data

# Start WebLogic Installation
RUN su - domibus -c \
   " \
   export JAVA_HOME="`ls -1 /usr/local/java | grep jdk1.7 | tail -1`" ; \
   export PATH=/usr/local/java/${JAVA_HOME}/bin:${PATH} ; \
   /data/WebLogic/install_weblogic.sh \
   "

#RUN su - domibus -c "/data/WebLogic/createDomain.sh /data/WebLogic/weblogic_domain.properties"

# This container do not start any service nor export them

CMD bash
