# tearing it down if exists
oc delete all --selector logging-infra=elasticsearch
#oc delete all --selector logging-infra=fluentd
oc delete all --selector logging-infra=kibana
oc delete all,sa,secret,oauthclient --selector logging-infra=support

# setting it up
oc process -f support.yaml -v KB_OAP_OAUTH_SECRET=12345,KB_OAP_OAUTH_SECRET_BASE64="$(echo -n 12345 | base64)",ES_OAP_SERVER_KEY="$(base64 hack/ssl/secret/server-key)",ES_OAP_SERVER_CERT="$(base64 hack/ssl/secret/server-cert)",ES_OAP_SERVER_TLS="$(base64 hack/ssl/secret/server-tls.json)",ES_OAP_CLIENT_KEY="$(base64 hack/ssl/fluentd-elasticsearch/fluentd-elasticsearch.key)",ES_OAP_CLIENT_CERT="$(base64 hack/ssl/fluentd-elasticsearch/fluentd-elasticsearch.crt)",ES_OAP_BACKEND_CA="$(base64 hack/ssl/fluentd-elasticsearch/root-ca.crt)",ES_KEY_STORE="$(base64 hack/ssl/es-logging/es-logging-keystore.jks)",ES_TRUST_STORE="$(base64 hack/ssl/es-logging/truststore.jks)",FLUENTD_ES_CLIENT_KEY="$(base64 hack/ssl/fluentd-elasticsearch/fluentd-elasticsearch.key)",FLUENTD_ES_CLIENT_CERT="$(base64 hack/ssl/fluentd-elasticsearch/fluentd-elasticsearch.crt)",FLUENTD_ES_CA="$(base64 hack/ssl/fluentd-elasticsearch/root-ca.crt)",KIBANA_ES_CLIENT_KEY="$(base64 hack/ssl/kibana/kibana.key)",KIBANA_ES_CLIENT_CERT="$(base64 hack/ssl/kibana/kibana.crt)",KIBANA_ES_CA="$(base64 hack/ssl/kibana/root-ca.crt)",KIBANA_HOSTNAME=kibana.apps.dev.example.com  | oc create -f -
oc process -f es.yaml -v OAP_MASTER_URL=https://master.dev.example.com:8443,OAP_DEBUG=true | oc create -f -
oc process -f kibana.yaml -v OAP_PUBLIC_MASTER_URL=https://master.dev.example.com:8443,OAP_MASTER_URL=https://master.dev.example.com:8443,OAP_DEBUG=true | oc create -f -
oc process -f fluentd.yaml -v MASTER_URL=https://master.dev.example.com:8443 > fluentd-static-pod.yaml

cat <<OUTPUT
Copy fluentd-static-pod.yaml to the static pod directory on each node.

If you haven't already, run this command:
oc edit securitycontextconstraints/privileged

And add the following line:
- system:serviceaccount:default:aggregated-logging

OUTPUT

