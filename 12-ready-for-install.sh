echo "STEP：Create rhcos-iso and ignition Download Files"

chmod -R 705 ${RHCOS_ISO_PATH}/*
cat << EOF > /etc/httpd/conf.d/rhcos.conf
Alias /rhcos-iso "${RHCOS_ISO_PATH}"
<Directory "${RHCOS_ISO_PATH}">
  Options +Indexes +FollowSymLinks
  Require all granted
</Directory>
<Location /rhcos >
  SetHandler None
</Location>
EOF

chmod -R 705 ${IGN_PATH}/*.ign
cat << EOF > /etc/httpd/conf.d/ignition.conf
Alias /ignition "${IGN_PATH}/../"
<Directory "${IGN_PATH}/../">
  Options +Indexes +FollowSymLinks
  Require all granted
</Directory>
<Location /ignition >
  SetHandler None
</Location>
EOF

systemctl restart httpd

echo =============================================================================================
echo ========================== All Files Will Be Download When Booting ==========================
verifyURL http://${YUM_DOMAIN}/ignition/${OCP_CLUSTER_ID}/bootstrap.ign
verifyURL http://${YUM_DOMAIN}/ignition/${OCP_CLUSTER_ID}/master.ign
verifyURL http://${YUM_DOMAIN}/ignition/${OCP_CLUSTER_ID}/worker.ign
verifyURL ${RHCOS_METAL_URL}