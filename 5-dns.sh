echo "STEPï¼Install BIND Service"
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
nmcli connection modify ${NET_IF_NAME} ipv4.dns ${DNS_IP}
nmcli connection modify ${NET_IF_NAME} ipv4.gateway ${GATEWAY_IP}
systemctl restart network

yum -y install bind bind-utils
systemctl enable named --now
restoreFile /etc/named.rfc1912.zones
restoreFile /etc/named.conf
sed -i -e "s/listen-on port.*/listen-on port 53 { any; };/" /etc/named.conf
sed -i -e "s/allow-query.*/allow-query { any; };/" /etc/named.conf

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
cat >> /etc/named.rfc1912.zones << EOF

zone "${DOMAIN}" IN {
        type master;
        file "${DOMAIN}.zone";
        allow-transfer { any; };
};

zone "${OCP_CLUSTER_ID}.${DOMAIN}" IN {
        type master;
        file "${OCP_CLUSTER_ID}.${DOMAIN}.zone";
        allow-transfer { any; };
};

zone "${NET_SEGMENT_PI}.in-addr.arpa" IN {
        type master;
        file "${NET_SEGMENT_PI}.in-addr.arpa.zone";
        allow-transfer { any; };
};

EOF
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
cat > /var/named/${DOMAIN}.zone << EOF
\$ORIGIN ${DOMAIN}.
\$TTL 1D
@           IN SOA  ${DOMAIN}. admin.${DOMAIN}. (
                                        0          ; serial
                                        1D         ; refresh
                                        1H         ; retry
                                        1W         ; expire
                                        3H )       ; minimum

@             IN NS                         dns.${DOMAIN}.

bastion       IN A                          ${BASTION_IP}
support       IN A                          ${SUPPORT_IP}
dns           IN A                          ${DNS_IP}
ntp           IN A                          ${NTP_IP}
yum           IN A                          ${YUM_IP}
registry      IN A                          ${REGISTRY_IP}
nfs           IN A                          ${NFS_IP}

EOF
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
cat > /var/named/${OCP_CLUSTER_ID}.${DOMAIN}.zone << EOF
\$ORIGIN ${OCP_CLUSTER_ID}.${DOMAIN}.
\$TTL 1D
@           IN SOA  ${OCP_CLUSTER_ID}.${DOMAIN}. admin.${OCP_CLUSTER_ID}.${DOMAIN}. (
                                        0          ; serial
                                        1D         ; refresh
                                        1H         ; retry
                                        1W         ; expire
                                        3H )       ; minimum

@             IN NS                         dns.${DOMAIN}.

lb             IN A                          ${LB_IP}

api            IN A                          ${LB_IP}
api-int        IN A                          ${LB_IP}
*.apps         IN A                          ${LB_IP}

bootstrap      IN A                          ${BOOTSTRAP_IP}

master-0       IN A                          ${MASTER0_IP}
master-1       IN A                          ${MASTER1_IP}
master-2       IN A                          ${MASTER2_IP}

etcd-0         IN A                          ${MASTER0_IP}
etcd-1         IN A                          ${MASTER1_IP}
etcd-2         IN A                          ${MASTER2_IP}

worker-0       IN A                          ${WORKER0_IP}
worker-1       IN A                          ${WORKER1_IP}

_etcd-server-ssl._tcp.${OCP_CLUSTER_ID}.${DOMAIN}. 8640 IN SRV 0 10 2380 etcd-0.${OCP_CLUSTER_ID}.${DOMAIN}.
_etcd-server-ssl._tcp.${OCP_CLUSTER_ID}.${DOMAIN}. 8640 IN SRV 0 10 2380 etcd-1.${OCP_CLUSTER_ID}.${DOMAIN}.
_etcd-server-ssl._tcp.${OCP_CLUSTER_ID}.${DOMAIN}. 8640 IN SRV 0 10 2380 etcd-2.${OCP_CLUSTER_ID}.${DOMAIN}.

EOF
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
cat > /var/named/${NET_SEGMENT_PI}.in-addr.arpa.zone << EOF
\$TTL 1D
@           IN SOA  ${DOMAIN}. admin.${DOMAIN}. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
                                        
@                              IN NS       dns.${DOMAIN}.

${BASTION_PI}.in-addr.arpa.     IN PTR      bastion.${DOMAIN}.

${SUPPORT_PI}.in-addr.arpa.     IN PTR      support.${DOMAIN}.
${DNS_PI}.in-addr.arpa.     IN PTR      dns.${DOMAIN}.
${NTP_PI}.in-addr.arpa.     IN PTR      ntp.${DOMAIN}.
${YUM_PI}.in-addr.arpa.     IN PTR      yum.${DOMAIN}.
${REGISTRY_PI}.in-addr.arpa.     IN PTR      registry.${DOMAIN}.
${NFS_PI}.in-addr.arpa.     IN PTR      nfs.${DOMAIN}.

${LB_PI}.in-addr.arpa.     IN PTR      lb.${OCP_CLUSTER_ID}.${DOMAIN}.
${LB_PI}.in-addr.arpa.     IN PTR      api.${OCP_CLUSTER_ID}.${DOMAIN}.
${LB_PI}.in-addr.arpa.     IN PTR      api-int.${OCP_CLUSTER_ID}.${DOMAIN}.

${BOOTSTRAP_PI}.in-addr.arpa.    IN PTR      bootstrap.${OCP_CLUSTER_ID}.${DOMAIN}.

${MASTER0_PI}.in-addr.arpa.    IN PTR      master-0.${OCP_CLUSTER_ID}.${DOMAIN}.
${MASTER1_PI}.in-addr.arpa.    IN PTR      master-1.${OCP_CLUSTER_ID}.${DOMAIN}.
${MASTER2_PI}.in-addr.arpa.    IN PTR      master-2.${OCP_CLUSTER_ID}.${DOMAIN}.

${WORKER0_PI}.in-addr.arpa.    IN PTR      worker-0.${OCP_CLUSTER_ID}.${DOMAIN}.
${WORKER1_PI}.in-addr.arpa.    IN PTR      worker-1.${OCP_CLUSTER_ID}.${DOMAIN}.

EOF
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
systemctl restart named
rndc reload
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
checkDNSIP() {
  if [ "$(dig ${1} +short)" != "${2}" ]
  then
    echo "ERROR DNS with ${1}"
  else
    echo "${1} DNS is right"
  fi
}
#
echo --------------------- Forward Check DNS---------------------
checkDNSIP bastion.${DOMAIN} "$BASTION_IP"
checkDNSIP nfs.${DOMAIN} "$NFS_IP"
checkDNSIP dns.${DOMAIN} "$DNS_IP"
checkDNSIP yum.${DOMAIN} "$YUM_IP"
checkDNSIP registry.${DOMAIN} "$REGISTRY_IP"
checkDNSIP ntp.${DOMAIN} "$NTP_IP"
checkDNSIP lb.${OCP_CLUSTER_ID}.${DOMAIN}  "$LB_IP"
checkDNSIP api.${OCP_CLUSTER_ID}.${DOMAIN} "$LB_IP"
checkDNSIP api-int.${OCP_CLUSTER_ID}.${DOMAIN}  "$LB_IP"
checkDNSIP *.apps.${OCP_CLUSTER_ID}.${DOMAIN} "$LB_IP"
checkDNSIP bootstrap.${OCP_CLUSTER_ID}.${DOMAIN} "$BOOTSTRAP_IP"
checkDNSIP master-0.${OCP_CLUSTER_ID}.${DOMAIN}  "$MASTER0_IP"
checkDNSIP master-1.${OCP_CLUSTER_ID}.${DOMAIN}  "$MASTER1_IP"
checkDNSIP master-2.${OCP_CLUSTER_ID}.${DOMAIN}  "$MASTER2_IP"
checkDNSIP etcd-0.${OCP_CLUSTER_ID}.${DOMAIN} "$MASTER0_IP"
checkDNSIP etcd-1.${OCP_CLUSTER_ID}.${DOMAIN} "$MASTER1_IP"
checkDNSIP etcd-2.${OCP_CLUSTER_ID}.${DOMAIN} "$MASTER2_IP"
checkDNSIP worker-0.${OCP_CLUSTER_ID}.${DOMAIN} "$WORKER0_IP"
checkDNSIP worker-1.${OCP_CLUSTER_ID}.${DOMAIN} "$WORKER1_IP"
echo --------------------- Reverse Check DNS---------------------
echo -e "$BASTION_IP related DNS is $(dig -x $BASTION_IP +short)"
echo -e "$SUPPORT_IP related DNS is \n$(dig -x $SUPPORT_IP +short)"
echo -e "$BOOTSTRAP_IP related DNS is $(dig -x $BOOTSTRAP_IP +short)"
echo -e "$MASTER0_IP related DNS is $(dig -x $MASTER0_IP +short)"
echo -e "$MASTER1_IP related DNS is $(dig -x $MASTER1_IP +short)"
echo -e "$MASTER2_IP related DNS is $(dig -x $MASTER2_IP +short)"
echo -e "$WORKER0_IP related DNS is $(dig -x $WORKER0_IP +short)"
echo -e "$WORKER1_IP related DNS is $(dig -x $WORKER1_IP +short)"

echo =============================================================================================
echo ==================================== Complete DNS Config ====================================
