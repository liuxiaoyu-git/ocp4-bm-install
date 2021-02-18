echo "STEP：Install Docker Registry"

mkdir -p ${REGISTRY_PATH}/{auth,certs,data}
openssl req -newkey rsa:4096 -nodes -sha256 -x509 -days 365 \
  -keyout ${REGISTRY_PATH}/certs/registry.key -out ${REGISTRY_PATH}/certs/registry.crt \
  -subj "/C=CN/ST=BEIJING/L=BJ/O=REDHAT/OU=IT/CN=registry.${DOMAIN}/emailAddress=admin@${DOMAIN}"
htpasswd -bBc ${REGISTRY_PATH}/auth/htpasswd openshift redhat
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
yum -y install docker-distribution
#
cat << EOF > /etc/docker-distribution/registry/config.yml
version: 0.1
log:
  fields:
    service: registry
storage:
    cache:
        layerinfo: inmemory
    filesystem:
        rootdirectory: ${REGISTRY_PATH}/data
    delete:
        enabled: false
auth:
  htpasswd:
    realm: basic-realm
    path: ${REGISTRY_PATH}/auth/htpasswd
http:
    addr: 0.0.0.0:5000
    host: https://${REG_DOMAIN}
    tls:
      certificate: ${REGISTRY_PATH}/certs/registry.crt
      key: ${REGISTRY_PATH}/certs/registry.key
EOF
#
systemctl enable docker-distribution --now
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
echo "STEP：Prepare Images for Installing OCP "

tar -xzf ${OCP_PATH}/ocp-client/openshift-client-linux-${OCP_VER}.tar.gz -C /usr/local/sbin/
yum -y install podman skopeo jq
\cp ${REGISTRY_PATH}/certs/registry.crt /etc/pki/ca-trust/source/anchors/ > /dev/null 2>&1
update-ca-trust
podman login -u openshift -p redhat --authfile ${REG_SECRET} ${REG_DOMAIN}
tar -xvf ${OCP_PATH}/ocp-image/ocp-image-${OCP_VER}.tar -C ${OCP_PATH}/ocp-image/
#rm -f ${OCP_PATH}/ocp-image/ocp-image-${OCP_VER}.tar
oc image mirror -a ${REG_SECRET} --dir=${OCP_PATH}/ocp-image/mirror_${OCP_VER} file://openshift/release:${OCP_VER}* ${REG_DOMAIN}/${REPO_NAME}

echo =============================================================================================
echo "===================== $(curl -u openshift:redhat -s https://${REG_DOMAIN}/v2/${REPO_NAME}/tags/list | jq -M '.["tags"][]' | wc -l) images have been imported to docker registry ====================="
