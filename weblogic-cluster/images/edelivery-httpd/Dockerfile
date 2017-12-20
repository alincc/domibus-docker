FROM httpd:2.4

# specify each corner public access hostname
ENV VHOST_CORNER_HOSTNAME=corner_vhost_hostname

# the vhosts domain to be used by the sticky session cookie
ENV VHOST_CORNER_DOMAIN=corner_vhost_domain

# each corner WebLogic Cluster node hostname and port, to be used by the load balancer
ENV CORNER_WL_NODE1_HOSTNAME=corner_weblogic_node1_hostname
ENV CORNER_WL_NODE1_PORT=corner_weblogic_node1_port
ENV CORNER_WL_NODE2_HOSTNAME=corner_weblogic_node2_hostname
ENV CORNER_WL_NODE2_PORT=corner_weblogic_node2_port

# in order to be able to use additional terminal capabilities
ENV TERM=xterm-256color

# turn off the package manager interactive mode during the image build
ENV DEBIAN_FRONTEND noninteractive

# Set the correct timezone
ENV TZ=Europe/Brussels
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
ADD resources/vhost_corner.conf /usr/local/apache2/conf/vhosts.d/

# update the vhosts configuration
# RUN sed -i "s/VHOST_CORNER_HOSTNAME/${VHOST_CORNER_HOSTNAME}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner.conf && \
#    sed -i "s/VHOST_CORNER_DOMAIN/${VHOST_CORNER_DOMAIN}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner.conf && \
#    sed -i "s/CORNER_WL_NODE1_HOSTNAME/${CORNER_WL_NODE1_HOSTNAME}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner.conf && \
#    sed -i "s/CORNER_WL_NODE1_PORT/${CORNER_WL_NODE1_PORT}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner.conf && \
#    sed -i "s/CORNER_WL_NODE2_HOSTNAME/${CORNER_WL_NODE2_HOSTNAME}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner.conf && \
#    sed -i "s/CORNER_WL_NODE2_PORT/${CORNER_WL_NODE2_PORT}/g" /usr/local/apache2/conf/vhosts.d/vhost_corner.conf

# set the correct permissions for the copied files
RUN chown -R root:www-data /usr/local/apache2/conf/

# turn off the package manager interactive mode during the image build
ENV DEBIAN_FRONTEND noninteractive
