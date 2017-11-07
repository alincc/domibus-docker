# This is an Offline WLST script to create a WLS 10.3.4 (Oracle Weblogic Server 11gR1) Domain
#
# Domain consists of:
# 1. Admin Server
# 2. Two Managed Servers for a Cluster
# 3. One Standalone Managed Server
# 4. A Cluster for Two Managed Server
# 5. One Machine which all Managed Servers will be configured
# Read a domain template
# Change the path to wls.jar according to your setup
print('Reading Template - /data/WebLogic/wls_12.1.3.0.0/Oracle/Middleware/Oracle_Home/wlserver/common/templates/wls/wls.jar')
readTemplate('/data/WebLogic/wls_12.1.3.0.0/Oracle/Middleware/Oracle_Home/wlserver/common/templates/wls/wls.jar')

# Admin Server SSL and Non-SSL
print('Creating Server - Admin Server')
cd('Servers/AdminServer')
set('ListenAddress','b4edelivery02')
set('ListenPort', 7101)

create('AdminServer','SSL')
cd('SSL/AdminServer')
set('Enabled', 'False')
set('ListenPort', 7102)

# Security
print('Creating Password')
cd('/')
cd('Security/base_domain/User/weblogic')
cmo.setPassword('1Domibus')

# Start Up
print('Setting StartUp Options')

# Next line commented: Only valid for Windows
#setOption('CreateStartMenu', 'false')
setOption('ServerStartMode', 'prod')
# Setting the JDK home. Change the path to your installed JDK for weblogic
setOption('JavaHome','/data/JDK/jdk1.7.0_79')
setOption('OverwriteDomain', 'true')

# Create Domain to File System
print('Writing Domain To File System')
# Change the path to your domain accordingly
writeDomain('/data/dhenech/titato')
closeTemplate()

# Read the Created Domain
print('Reading the Domain from In Offline Mode')
readDomain('/data/dhenech/titato')

# Creating Managed Server
#Change the ports accordingly for domibus01
print('Creating Server - domibus01 on Port # 7103')
cd('/')
create('domibus01', 'Server')
cd('Server/domibus01')
set('ListenPort', 7102)
set('ListenAddress', 'b4edelivery02')

# updating the changes
print('Finalizing the changes')
updateDomain()
closeDomain()

# Exiting
print('Exiting...')
exit()
