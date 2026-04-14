#!/bin/bash

export ACCOUNT_ROOT='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGeuX8g1ZXEiHlUx1vyQvWRy+mRxePGtcLHlsgLGxt+g9oGBV/5qcvyJnq0OZaWoRFmtKDNmabwMAA8ws4MW4vsYqzyLyFM9ujv/oWYZTMj7yskm5bNMWLrN0gNjzXkeQFOMHI3IpeCHETlxAs3iwcBa3/mXgF5VcPsEid5zv6sFqEDA4hNq7qqhjeUn6XlggllE8+KVPrq1fvs3MJIrWb2hYI2JlJxo5PuNWvG1Yj3AFQZMdIBrx54YawBXSZD7IqwYep1RJzrGLOaOzK/QNFnERARCnvLkJ3lLXc0/snr5F50O29DhYQFqZffHAyUtcWHQjqeIL38Ib5oWiXOYZc7MuexShj2nyPX9VeCkrOUZBLgDJ6k9N49AxlsqjI53i5/j0RsdVal7uyK2ghhbk/kg3jqNN5zPckAMCY3V3lF9ZelwNEVl1HcUr+NSf/j3EkbkkDn8FUeU7qqrXKz1P5R73B3WAo+6/20+4ZUZlgz4vPo+qIMEQZITbbpnukjbvU2TbZzYXYj2IohL6pcZzq9Hff13QxYqhp/7CPE4wvFAy1KxtLyKAlrGEjzoEUUf622Us+KqZXOFpbFHoUbLoPKslk55MRx5rQ7Af3QbJWTje/ITjtb3qjsfH2Bjiqe6ERAfFF7p+p3CMJfXxjrqCq24pce69JqwGK4WMKo1yKEQ== root@*.ifinch.eu'

#######

export ACCOUNT_MAINTENANCE='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHBWDI2Bo6MBu7D9gO9rFAFqInilB8aqlKLpJJvnE52yU13DMvvY6Xsl5WlNVzR0NqgphwhYr3oAqAIUacMh3lE2FsFaou+3F02CEp+Zsxrkrtbp5q/9z+EB73PSWMrqh8Ju9AvB/mJtNGoZjqSWj/JkRap79+IoA0uNZidfifOEqn7c5SOWvtO18oAP7uxwUB4K4q6x+t0+6Kuh9FLTHzSq/WASmAaCstFRta6Oibg7bAcJgCKwuL04tYCZ46y/sRTr1DoX0bq1yMLdvL908JE6DE8qkbr37pgk/lLqRFYbJwoRpe5NxJrwDDe5LLVE7R8VcfPciYTlURgN7oHvK6sPqZYafwylRzKZ6qa1ouU6hYc7gRnWwMn/rPVuvGgW7LE1mBNkzaUgqu/v4VEiTV1KkOvXhnTbjFrAaySKcHGiiKIW3Ok1TUH+lbwuSU5qDfr4A/W1EK9aKJniRQ71Y5AkkU7mwyrCKKE/tCuaMZhnLMz0zX6OaT57QeVp41cg8ZxJnnJNZLudRCZDUzLJSlcn1Ib0EDw0NT2AGFk257NegtDaW9XYTxjKxLo7Fd9Dk1uzTm4wYvCC6BeUnS4Lodk5a24gLsdffDQt57UbuPjSVq9DhNpGBOpSDO1dkwUTWbL5eg5ZDsYswSA2ysGBPuUUDqbUtK3MqjRg+z2EaGcw== maintenance@*.ifinch.eu'
export MAINTENANCE_HOME='/home/maintenance'

#################################################

chattr -i /root/.ssh 2> /dev/null
chattr -i /root/.ssh/authorized_keys 2> /dev/null
tar -cpzf /var/backups/root_backup_$(date +%Y%m%d_%H%M%S).tar.gz --exclude=/var/backups /root
rm -rf /root/* /root/.* 2> /dev/null
cp -rT /etc/skel /root
mkdir -p /root/.ssh
echo "${ACCOUNT_ROOT}" > /root/.ssh/authorized_keys
chown -R root:root /root
chmod 0700 /root/.ssh
chmod 0600 /root/.ssh/authorized_keys
if [[ -n "$(which restorecon)" ]]; then restorecon -Rv /root/.ssh; fi
#chattr +i /root/.ssh/authorized_keys

#######

chattr -i "${MAINTENANCE_HOME}/.ssh" 2> /dev/null
chattr -i "${MAINTENANCE_HOME}/.ssh/authorized_keys" 2> /dev/null
userdel -rf maintenance 2> /dev/null
useradd --system -d "${MAINTENANCE_HOME}" -m -g nogroup -s /bin/bash -c "Maintenance account" -N maintenance 2> /dev/null
mkdir -p "${MAINTENANCE_HOME}/.ssh"
echo "${ACCOUNT_MAINTENANCE}" > "${MAINTENANCE_HOME}/.ssh/authorized_keys"
chown -R maintenance:nogroup "${MAINTENANCE_HOME}"
chmod -R 0700 "${MAINTENANCE_HOME}"
chmod 0600 "${MAINTENANCE_HOME}/.ssh/authorized_keys"
if [[ -n "$(which restorecon)" ]]; then restorecon -Rv "${MAINTENANCE_HOME}/.ssh"; fi
#chattr +i "${MAINTENANCE_HOME}/.ssh/authorized_keys"

if [[ -z "$(which sudo)" ]]; then (apt-get update -y && apt-get install sudo -y); fi
chattr -i /etc/sudoers.d/maintenance 2> /dev/null
echo 'maintenance  ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/maintenance
#chattr +i /etc/sudoers.d/maintenance

#################################################

find /var/backups -name "root_backup_*.tar.gz" -mtime +3 -delete

echo "Done!"
