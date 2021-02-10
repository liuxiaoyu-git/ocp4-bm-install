echo "STEP: Install HAProxy"

yum -y install haproxy
systemctl enable haproxy --now
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
cat <<EOF > /etc/haproxy/haproxy.cfg

global
    maxconn     20000
    log         /dev/log local0 info
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    user        haproxy
    group       haproxy
    daemon

    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          300s
    timeout server          300s
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 20000

listen stats
    bind :9000
    mode http
    stats enable
    stats uri /

frontend  openshift-api-server-${OCP_CLUSTER_ID}
    bind lb.${OCP_CLUSTER_ID}.${DOMAIN}:6443
    mode tcp
    option tcplog
    default_backend openshift-api-server-${OCP_CLUSTER_ID}

frontend  machine-config-server-${OCP_CLUSTER_ID}
    bind lb.${OCP_CLUSTER_ID}.${DOMAIN}:22623
    mode tcp
    option tcplog
    default_backend machine-config-server-${OCP_CLUSTER_ID}

frontend  ingress-http-${OCP_CLUSTER_ID}
    bind lb.${OCP_CLUSTER_ID}.${DOMAIN}:80
    mode tcp
    option tcplog
    default_backend ingress-http-${OCP_CLUSTER_ID}

frontend  ingress-https-${OCP_CLUSTER_ID}
    bind lb.${OCP_CLUSTER_ID}.${DOMAIN}:443
    mode tcp
    option tcplog
    default_backend ingress-https-${OCP_CLUSTER_ID}

backend openshift-api-server-${OCP_CLUSTER_ID}
    balance source
    mode tcp
    server     bootstrap bootstrap.${OCP_CLUSTER_ID}.${DOMAIN}:6443 check
    server     master-0 master-0.${OCP_CLUSTER_ID}.${DOMAIN}:6443 check
    server     master-1 master-1.${OCP_CLUSTER_ID}.${DOMAIN}:6443 check
    server     master-2 master-2.${OCP_CLUSTER_ID}.${DOMAIN}:6443 check

backend machine-config-server-${OCP_CLUSTER_ID}
    balance source
    mode tcp
    server     bootstrap bootstrap.${OCP_CLUSTER_ID}.${DOMAIN}:22623 check
    server     master-0 master-0.${OCP_CLUSTER_ID}.${DOMAIN}:22623 check
    server     master-1 master-1.${OCP_CLUSTER_ID}.${DOMAIN}:22623 check
    server     master-2 master-2.${OCP_CLUSTER_ID}.${DOMAIN}:22623 check

backend ingress-http-${OCP_CLUSTER_ID}
    balance source
    mode tcp
    server     worker-0 worker-0.${OCP_CLUSTER_ID}.${DOMAIN}:80 check
    server     worker-1 worker-1.${OCP_CLUSTER_ID}.${DOMAIN}:80 check

backend ingress-https-${OCP_CLUSTER_ID}
    balance source
    mode tcp
    server     worker-0 worker-0.${OCP_CLUSTER_ID}.${DOMAIN}:443 check
    server     worker-1 worker-1.${OCP_CLUSTER_ID}.${DOMAIN}:443 check

EOF
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
systemctl restart haproxy
sleep 40s
echo =============================================================================================
echo =================== Complete HAProxy Config and Waiting for Running ... =====================
echo ============================== All Ports HAProxy Listened Are ===============================
ss -lntp | grep haproxy
