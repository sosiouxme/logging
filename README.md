# logging
The purpose of this repo is to create the images of the logging stack
via Dockerfiles `cd hack; sh build-images.sh` and then deploy them via
templates as demonstrated in example-create.sh

You will need to generate all the necessary certs/keys/etc and fill them
into the templates as demonstrated in example-create.sh -- currently a tedious task.

To use the mutual auth to connect to ElasticSearch you will need
to create a JKS keychain and truststore for Elasticsearch, and
unencrypted certificates and pkeys for Fluentd and Kibana.  The script
hack/ssl/generateExampleKeys.sh will do this for you. Generating the
parameters for the two openshift-auth-proxy definitions is not described
yet, sorry.

Running fluentd requires some special attention.

Fluentd has its own service account which must be specially enabled
to allow it to read node logs and gather pod metadata from the master.
To allow fluentd to run as a privileged container so it can read node
logs, you will need to add the account to the privileged SCC. This is
accomplished as follows:

    oc edit securitycontextconstraints/privileged

And add the following line at the end:

    - system:serviceaccount:default:fluentd

To allow fluentd to list all pods in the cluster, you will need
to update the role of your service account.

    oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:default:fluentd

Finally, creating the fluentd pod. You can just plain create it:

    oc create -f fluentd-static-pod.yaml

Of course this won't deploy it on all the nodes, just a single
one, and it won't keep revive it if it dies or openshift-node
goes down. To do that, you need a static pod definition. So
copy it to all your nodes under the path configured for them
to read and create static pod definitions [as described in the
docs](https://docs.openshift.org/latest/admin_guide/aggregate_logging.html#creating-logging-pods).
