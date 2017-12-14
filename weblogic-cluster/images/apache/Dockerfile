FROM httpd:2.4

# specify each corner public access hostname
ARG VHOST_C2_HOSTNAME=corner2_vhost_hostname
ARG VHOST_C3_HOSTNAME=corner3_vhost_hostname

# the vhosts domain to be used by the sticky session cookie
ARG VHOST_C2_DOMAIN=corner2_vhost_domain
ARG VHOST_C3_DOMAIN=corner3_vhost_domain

# each corner WebLogic Cluster node hostname and port, to be used by the load balancer
ARG C2_WL_NODE1_HOSTNAME=corner2_weblogic_node1_hostname
ARG C2_WL_NODE1_PORT=corner2_weblogic_node1_port
ARG C2_WL_NODE2_HOSTNAME=corner2_weblogic_node2_hostname
ARG C2_WL_NODE2_PORT=corner2_weblogic_node2_port
ARG C3_WL_NODE1_HOSTNAME=corner3_weblogic_node1_hostname
ARG C3_WL_NODE1_PORT=corner3_weblogic_node1_port
ARG C3_WL_NODE2_HOSTNAME=corner3_weblogic_node2_hostname
ARG C3_WL_NODE2_PORT=corner3_weblogic_node2_port

# in order to be able to use additional terminal capabilities
ENV TERM=xterm-256color

# turn off the package manager interactive mode during the image build
ENV DEBIAN_FRONTEND noninteractive

# Set the correct timezone
ENV TZ=Europe/Lisbon
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# install some useful packages
RUN apt-get update && apt-get install -y unzip net-tools vim wget && \
# activate vim syntax highlight
    sed -i 's/"syntax on/syntax on/g' /etc/vim/vimrc && \
# activate history search via PgUp/PgDown keys
    sed -i 's/# "\\e\[5~": history-search-backward/"\\e\[5~": history-search-backward/g' /etc/inputrc && \
    sed -i 's/# "\\e\[6~": history-search-forward/"\\e\[6~": history-search-forward/g' /etc/inputrc && \
# create apache httpd vhosts directory
    mkdir /usr/local/apache2/conf/vhosts.d

# add configuration files and other related files
ADD resources/httpd-default.conf /usr/local/apache2/conf/extra/
ADD resources/httpd.conf /usr/local/apache2/conf/
ADD resources/vhost*.conf /usr/local/apache2/conf/vhosts.d/

# update the vhosts configuration
RUN sed -i "s/VHOST_C2_HOSTNAME/${VHOST_C2_HOSTNAME}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner2.conf && \
    sed -i "s/VHOST_C3_HOSTNAME/${VHOST_C3_HOSTNAME}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner3.conf && \
    sed -i "s/VHOST_C2_DOMAIN/${VHOST_C2_DOMAIN}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner2.conf && \
    sed -i "s/VHOST_C3_DOMAIN/${VHOST_C3_DOMAIN}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner3.conf && \
    sed -i "s/C2_WL_NODE1_HOSTNAME/${C2_WL_NODE1_HOSTNAME}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner2.conf && \
    sed -i "s/C3_WL_NODE1_HOSTNAME/${C3_WL_NODE1_HOSTNAME}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner3.conf && \
    sed -i "s/C2_WL_NODE1_PORT/${C2_WL_NODE1_PORT}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner2.conf && \
    sed -i "s/C3_WL_NODE1_PORT/${C3_WL_NODE1_PORT}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner3.conf && \
    sed -i "s/C2_WL_NODE2_HOSTNAME/${C2_WL_NODE2_HOSTNAME}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner2.conf && \
    sed -i "s/C3_WL_NODE2_HOSTNAME/${C3_WL_NODE2_HOSTNAME}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner3.conf && \
    sed -i "s/C2_WL_NODE2_PORT/${C2_WL_NODE2_PORT}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner2.conf && \
    sed -i "s/C3_WL_NODE2_PORT/${C3_WL_NODE2_PORT}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner3.conf

# set the correct permissions for the copied files
RUN chown -R root:www-data /usr/local/apache2/conf/

# turn off the package manager interactive mode during the image build
ENV DEBIAN_FRONTEND noninteractive
