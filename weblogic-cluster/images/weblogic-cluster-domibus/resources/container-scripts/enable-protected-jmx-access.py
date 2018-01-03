#
# Script to Enable Use Authorization Providers to Protect JMX Access
#
# Since: November, 2017
# Author: FERNANDES Henrique
#
# Reference: http://www.oracle.com/technetwork/articles/idm/customizing-wls-security-187222.html
# =============================
execfile('/u01/oracle/commonfuncs.py')

domain_name = os.environ.get("DOMAIN_NAME", "")
domain_home = os.environ.get("DOMAIN_HOME", "")

print('domain_name : [%s]' % domain_name);
print('domain_home : [%s]' % domain_home);

def useAuthorizationProvidersToProtectJMXAccess():
    cd('/SecurityConfiguration/%s/Realms/myrealm' % domain_name)
    set('DelegateMBeanAuthorization', 'true')

# Enable Use Authorization Providers to Protect JMX Access by default
print('Enable Use Authorization Providers to Protect JMX Access...');

readDomain(domain_home)
useAuthorizationProvidersToProtectJMXAccess()
updateDomain()
closeDomain()

exit()
