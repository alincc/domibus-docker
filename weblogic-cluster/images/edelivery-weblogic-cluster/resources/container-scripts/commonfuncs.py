import os
import socket

# Variables
# =========
# Environment Vars
hostname       = socket.gethostname()
# Admin Vars
admin_username = os.environ.get('ADMIN_USERNAME', 'weblogic')
admin_password = os.environ.get('ADMIN_PASSWORD') # this is read only once when creating domain (during docker image build)
admin_host     = os.environ.get('ADMIN_HOST', 'wlsadmin')
admin_port     = os.environ.get('ADMIN_PORT', '7001')
# Node Manager Vars
nmname         = os.environ.get('NM_NAME', 'Machine-' + hostname)

# Functions
def editMode():
    edit()
    # waitTimeInMillis (Optional)
    #   Time (in milliseconds) that WLST waits until it gets a lock, in the event that another user has a lock. This
    #   argument defaults to 0 ms.
    # exclusive (Optional)
    #   Specifies whether the edit session should be an exclusive session. If set to true, if the same owner enters the
    #   startEdit command, WLST waits until the current edit session lock is released before starting the new edit
    #   session. The exclusive lock times out according to the time specified in timeoutInMillis. This argument defaults
    #   to false.
    startEdit(waitTimeInMillis=600000, exclusive="true")

def saveActivate():
    save()
    activate(block="true")

def connectToAdmin():
    connect(url='t3://' + admin_host + ':' + admin_port, adminServerName='AdminServer')
