echo "STEP: Stop Firewall and SELINUX"

hostnamectl set-hostname support

systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld

SELINUX=$(getenforce)
echo $SELINUX
if [ $SELINUX = 'Enforcing' ]; then
  sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
  reboot
fi


echo =============================================================================================
echo ============================== Firewall is closed and SELINUX is ${SELINUX}. ================
