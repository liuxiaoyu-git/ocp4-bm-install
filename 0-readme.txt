*********************************************************************************************************
* 所有变量都在2-parameter.sh，安装前请确认变量参数。                                                    *
* 在运行5-dns.sh之前，需要将Support节点的DNS设置到它自己的IP，另外还需确认5-dns.sh文件中的反向解析网段。*
* Please copy each line and run one-by-one in Support Node as root.                                     *
*********************************************************************************************************

source ./1-security.sh
source ./2-parameter.sh
source ./3-precheck.sh
source ./4-local-yum.sh
source ./5-dns.sh
source ./6-http-yum.sh
source ./7-ntp.sh
source ./8-haproxy.sh
source ./9-registry.sh
source ./10-iso.sh
source ./11-install-config.sh
source ./12-ready-for-install.sh
