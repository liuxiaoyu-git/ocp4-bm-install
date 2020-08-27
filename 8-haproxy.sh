echo "STEP：Install HAProxy"

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
    bind  :9000
    mode http
    stats enable
    stats uri /

frontend  openshift-api-server
    bind  *:6443
    mode tcp
    option tcplog
    default_backend openshift-api-server

frontend  machine-config-server
    bind  *:22623
    mode tcp
    option tcplog
    default_backend machine-config-server

frontend  ingress-http
    bind  *:80
    mode tcp
    option tcplog
    default_backend ingress-http

frontend  ingress-https
    bind  *:443
    mode tcp
    option tcplog
    default_backend ingress-https

backend openshift-api-server
    balance source
    mode tcp
    server     bootstrap bootstrap.${OCP_CLUSTER_ID}.${DOMAIN}:6443 check
    server     master-0 master-0.${OCP_CLUSTER_ID}.${DOMAIN}:6443 check

backend machine-config-server
    balance source
    mode tcp
    server     bootstrap bootstrap.${OCP_CLUSTER_ID}.${DOMAIN}:22623 check
    server     master-0 master-0.${OCP_CLUSTER_ID}.${DOMAIN}:22623 check

backend ingress-http
    balance source
    mode tcp
    server     worker-0 worker-0.${OCP_CLUSTER_ID}.${DOMAIN}:80 check
    server     worker-1 worker-1.${OCP_CLUSTER_ID}.${DOMAIN}:80 check

backend ingress-https
    balance source
    mode tcp
    server     worker-0 worker-0.${OCP_CLUSTER_ID}.${DOMAIN}:443 check
    server     worker-1 worker-1.${OCP_CLUSTER_ID}.${DOMAIN}:443 check

EOF
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
systemctl restart haproxy

echo =============================================================================================
echo =================== Complete HAProxy Config and Waiting for Running ... =====================
echo ============================== All Ports HAProxy Listened Are ===============================
ss -lntp | grep haproxy
