*********************************************************************************************
* 请在完成《OCP4离线裸机部署手册-workshop》的“4.1上传安装介质”后再执行Shell，以加速安装操作 *
*********************************************************************************************

*********************************************************************************************
* 所有Shell用到的变量都在2-parameter.sh。安装前请确认变量参数，包括IP、软件版本、实例名等。 *
* 在运行5-dns.sh之前，需要将Support节点的DNS设置到它自己的IP。                              *
* Please copy each line and run one-by-one in Support Node as root.                         *
*********************************************************************************************

source ./0-setenv.sh
source ./0-download-ocp.sh

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

*********************************************************************************************
* 成功执行完全部Shell后，可继续参照《OCP4离线裸机部署手册-workshop》                        *
* “6 创建Bootstrap、Master、Worker虚拟机节点” 完成以后的安装操作。                          *
*********************************************************************************************
