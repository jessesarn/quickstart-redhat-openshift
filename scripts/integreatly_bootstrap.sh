#! /bin/bash

# Install Integreatly
MASTER_NODES=$(sudo oc get nodes | grep master | awk {'print $1'})
git clone --branch ${INTEGREATLY_RELEASE_VERSION} https://github.com/integr8ly/installation.git /tmp/integreatly
pushd /tmp/integreatly/evals
# Modify hosts file to set ssh user to root
perl -i -0pe "s/ec2-user/root/" inventories/hosts
# Modify hosts file to dynamically set master nodes
perl -i -0pe "s/\[master\]\n127.0.0.1\n/\[master\]\n$MASTER_NODES\n/" inventories/hosts
sudo ansible-playbook -i inventories/hosts playbooks/install.yml >> /var/log/integreatly_bootstrap.log
popd

if [ "${OCP_VERSION}" == "3.10" ]; then
    CURRENT_OP_FRAMEWORK_VERSION=https://github.com/operator-framework/operator-lifecycle-manager/archive/0.6.0.tar.gz
    curl  --retry 5  -Ls ${CURRENT_OP_FRAMEWORK_VERSION} -o operator-framework.tar.gz
    tar -zxf operator-framework.tar.gz
    sudo rm -rf /usr/share/opframework
    sudo mkdir -p /usr/share/opframework
    sudo mv operator-lifecycle-manager-*/* /usr/share/opframework/
    sudo kubectl apply -f /usr/share/opframework/deploy/upstream/manifests/0.4.0
fi