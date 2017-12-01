FROM centos

ARG JavaVersion

# Creating Extra Groups
RUN groupadd cefsup

# Creating extra Users
# domibus User (By default Locked)
RUN useradd domibus -G cefsup
RUN mkdir /home/domibus/.ssh
RUN chown domibus:domibus /home/domibus/.ssh
RUN chmod 700 /home/domibus/.ssh
#COPY SSH_Keys/id_rsa /home/domibus/.ssh/id_rsa
#RUN chown domibus:domibus /home/domibus/.ssh/id_rsa
#RUN chmod 700 /home/domibus/.ssh/id_rsa
#RUN mkdir /data/domibus
#RUN chown -R domibus:cefsup /data/domibus
RUN passwd -l domibus

# smp user (By default locked)
RUN useradd smp -G cefsup
RUN mkdir /home/smp/.ssh
RUN chown smp:smp /home/smp/.ssh
RUN chmod 700 /home/smp/.ssh
#COPY SSH_Keys/id_rsa /home/smp/.ssh/id_rsa
#RUN chown smp:smp /home/smp/.ssh/id_rsa
#RUN chmod 700 /home/smp/.ssh/id_rsa
#RUN mkdir /data/smp
#RUN chown -R smp:cefsup /data/smp
RUN passwd -l smp

# Creating extra Directories
RUN mkdir /temp
RUN chown root:cefsup /temp
RUN chmod 770 /temp

RUN mkdir /data
RUN chown root:cefsup /data
RUN chmod 770 /data

# Installing extra Utilities used to automate installation
RUN yum install wget -y
RUN yum install unzip -y
RUN yum install less -y
# httpd-tools will be used by Domibus to generate BCRYPT Hashes
RUN yum install httpd-tools -y
# MySQL Client will be used by Domibus to Create MySQL users/schemas
RUN yum install mysql -y

# Installing extra tools for debugging purpose
# Telnet can be use to test remote connectivity
RUN yum install telnet -y

# The which Utility
RUN yum install which -y

# The Dockerize Utility
#ENV DOCKERIZE_VERSION v0.5.0
#RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
#    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
#    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# JAVA Installation
RUN mkdir /usr/local/java
COPY temp/java /usr/local/java
## Unzipping java and deleting archives
#RUN cd /data/java ; javaZip=`ls -1` ; echo $javaZip ; tar xvfz $javaZip ; rm $javaZip
#RUN cd /data/java ; tar xvfs ${JavaVersion} ; rm ${JavaVersion}
#RUN cd /data/java ; javaDir=`ls -1` ; mv ${javaDir}/* . ; rm ${javaDir}

# Installing & Configuring JAVA System Wide
RUN for file in `ls -1 /usr/local/java` ; do cd /usr/local/java ; tar xvfz ${file} && rm ${file} ; done
RUN cd /usr/local/java ; javaDir=`ls -1 | tail -1` ; echo "export JAVA_HOME=/usr/local/java/${javaDir}" > /etc/profile.d/java_env.sh
RUN echo "export PATH=\${JAVA_HOME}/bin:\$PATH" >> /etc/profile.d/java_env.sh
RUN chmod +x /etc/profile.d/java_env.sh

#SQLPlus Installation
RUN yum install libaio -y
RUN mkdir -p /usr/local/Oracle
COPY temp/SQLPlus /usr/local/Oracle
RUN  cd /usr/local/Oracle ; for file in `ls -1 /usr/local/Oracle` ; do unzip ${file} && rm ${file} ; done && mv instantclient_12_2 SQLPlus
RUN echo "export PATH=\$PATH:/usr/local/Oracle/SQLPlus" > /etc/profile.d/sqlplus_env.sh && echo "export LD_LIBRARY_PATH=/usr/local/Oracle/SQLPlus" >> /etc/profile.d/sqlplus_env.sh 
RUN chmod +x /etc/profile.d/sqlplus_env.sh

CMD bash


