#!/usr/bin/env bash
curl https://mirror.openshift.com/pub/openshift-v3/clients/3.6.173.0.21/linux/oc.tar.gz | tar xvz
curl https://gist.githubusercontent.com/cescoffier/a6f5202d53d91eba65df6f7922c39d9a/raw/d33141976d9906585024b233bf062330a95abb28/oc-cleanup.sh > oc-cleanup.sh
chmod +x oc
chmod +x oc-cleanup.sh
./oc login ${OPENSHIFT_URL} -u ${OPENSHIFT_USER} -p ${OPENSHIFT_PWD} &> /dev/null
./oc project ${OPENSHIFT_PROJECT} &> /dev/null || ./oc new-project ${OPENSHIFT_PROJECT} &> /dev/null
./oc-cleanup.sh &> /dev/null
