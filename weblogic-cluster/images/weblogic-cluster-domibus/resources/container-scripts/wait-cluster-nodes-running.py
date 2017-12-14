#
# Script to wait for Cluster Nodes to reach the state RUNNING
#
# Since: November, 2017
# Author: FERNANDES Henrique
#
# =============================

#import time

execfile('/u01/oracle/commonfuncs.py')

# Vars
cluster_name = os.environ.get("CLUSTER_NAME", "DockerCluster")
cluster_servers = os.environ.get("CLUSTER_SERVERS", 2)
retry_count = 20

print('cluster_name : [%s]' % cluster_name);
print('cluster_servers : [%s]' % cluster_servers);
print('retry_count : [%s]' % retry_count);

# Function that verifies if all cluster nodes are in state RUNNING
def clusterNodesAreRunning():
    cluster = state(cluster_name, 'Cluster', returnMap="true")
    if len(cluster) != int(cluster_servers):
        print 'Cluster is not ready yet...'
        return False
    for node in cluster:
        node_state = cluster[node]
        if node_state != 'RUNNING':
            print 'Cluster is not ready yet...'
            return False
    print 'Cluster is ready.'
    return True

# MAIN

# Connect to AdminServer
connect(admin_username, admin_password, 't3://'+admin_host+':'+admin_port)

# Wait and retry until the cluster nodes are running
next_wait_time = 1
while not clusterNodesAreRunning():
    # Avoid startup AttributeError: java package 'weblogic.time' has no attribute 'sleep'
    import time
    print 'Retrying in %s seconds...' % next_wait_time
    time.sleep(next_wait_time)
    next_wait_time += 1
    if next_wait_time == retry_count:
        break
