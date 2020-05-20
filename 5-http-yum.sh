echo "STEP：Install Httpd Service and Config Formal Yum"

yum -y install httpd
systemctl enable httpd --now
\cp /etc/httpd/conf/httpd.conf.origin /etc/httpd/conf/httpd.conf > /dev/null 2>&1 || \cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.origin
sed -i -e 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
chmod -R 705 /data
cat << EOF > /etc/httpd/conf.d/yum.conf
Alias /repo "${YUM_PATH}"
<Directory "${YUM_PATH}">
  Options +Indexes +FollowSymLinks
  Require all granted
</Directory>
<Location /repo>
  SetHandler None
</Location>
EOF
systemctl restart httpd
#----------------------------------------------------------------------------
mv /etc/yum.repos.d/base.repo{,.bak} 
cat > /etc/yum.repos.d/ocp.repo << EOF
[rhel-7-server]
name=rhel-7-server
baseurl=http://${YUM_DOMAIN}/repo/rhel-7-server-rpms/
enabled=1
gpgcheck=0

[rhel-7-server-extras] 
name=rhel-7-server-extras
baseurl=http://${YUM_DOMAIN}/repo/rhel-7-server-extras-rpms/
enabled=1
gpgcheck=0

[rhel-7-server-ose-4.3-rpms] 
name=rhel-7-server-ose-4.3-rpms
baseurl=http://${YUM_DOMAIN}/repo/rhel-7-server-ose-4.3-rpms/
enabled=1
gpgcheck=0 

EOF
#
yum clean all
yum makecache

echo =============================================================================================
echo ================================= Complete Config Formal Yum ================================
verifyURL http://${YUM_DOMAIN}/repo/rhel-7-server-rpms/
verifyURL http://${YUM_DOMAIN}/repo/rhel-7-server-extras-rpms/
verifyURL http://${YUM_DOMAIN}/repo/rhel-7-server-ose-4.3-rpms/