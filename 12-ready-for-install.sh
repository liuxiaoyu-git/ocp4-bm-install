echo "STEP: Enable download ignition file"

chmod 604 ${IGN_PATH}/*.ign
chmod 604 ${IGN_PATH}/set-*
 
cat << EOF > /etc/httpd/conf.d/ignition.conf
Alias /${OCP_CLUSTER_ID} "${IGN_PATH}/../"
<Directory "${IGN_PATH}/../">
  Options +Indexes +FollowSymLinks
  Require all granted
</Directory>
<Location /${OCP_CLUSTER_ID}>
  SetHandler None
</Location>
EOF

systemctl restart httpd

echo =============================================================================================
echo ===================== These Files Must Be Downloaded When CoreOS Booting ====================
verifyURL http://${YUM_DOMAIN}/${OCP_CLUSTER_ID}/ignition/bootstrap.ign
verifyURL http://${YUM_DOMAIN}/${OCP_CLUSTER_ID}/ignition/master.ign
verifyURL http://${YUM_DOMAIN}/${OCP_CLUSTER_ID}/ignition/worker.ign
verifyURL http://${YUM_DOMAIN}/${OCP_CLUSTER_ID}/ignition/set-bootstrap
verifyURL http://${YUM_DOMAIN}/${OCP_CLUSTER_ID}/ignition/set-master-0
verifyURL http://${YUM_DOMAIN}/${OCP_CLUSTER_ID}/ignition/set-master-1
verifyURL http://${YUM_DOMAIN}/${OCP_CLUSTER_ID}/ignition/set-master-2
verifyURL http://${YUM_DOMAIN}/${OCP_CLUSTER_ID}/ignition/set-worker-0
verifyURL http://${YUM_DOMAIN}/${OCP_CLUSTER_ID}/ignition/set-worker-1
