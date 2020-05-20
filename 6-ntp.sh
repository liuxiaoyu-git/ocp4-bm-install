echo "STEP：Config Time Service"

timedatectl list-timezones |grep Asia/Shanghai
timedatectl set-timezone Asia/Shanghai
yum -y install chrony
systemctl enable chronyd --now
\cp /etc/chrony.conf.origin /etc/chrony.conf > /dev/null 2>&1 || \cp /etc/chrony.conf /etc/chrony.conf.origin
sed -i -e "s/^server*/#&/g" \
       -e "s/#local stratum 10/local stratum 10/g" \
       -e "s/#allow 192.168.0.0\/16/allow all/g" \
       /etc/chrony.conf
cat >> /etc/chrony.conf << EOF
server ntp.${DOMAIN} iburst
EOF

systemctl restart chronyd

echo =============================================================================================
echo ==================================== Complete NTP Config ====================================
chronyc sources -v