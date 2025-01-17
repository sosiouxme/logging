#! /bin/bash

nohup /usr/share/elasticsearch/bin/elasticsearch -Des.pidfile=/var/run/elasticsearch/elasticsearch.pid &

sleep 30; curl -XPUT 'http://localhost:9200/searchguard/ac/ac?pretty' -d '
{"acl": [
    {
      "__Comment__": "Default is to deny all access",
      "filters_bypass": [],
      "filters_execute": []
    },
    {
      "__Comment__": "This is so that fluentd can only write",
      "users": ["fluentd"],
      "filters_bypass": [],
      "filters_execute": ["actionrequestfilter.fluentd"]
    },
    {
      "__Comment__": "This is so that Kibana can do anything in the .kibana index",
      "users": ["kibana"],
      "indices": [".kibana"],
      "filters_bypass": ["*"],
      "filters_execute": []
    },
    {
      "__Comment__": "This is so that Kibana can only read in all indices",
      "users": ["kibana"],
      "filters_bypass": [],
      "filters_execute": ["actionrequestfilter.kibana"]
    }
]}'

/usr/share/elasticsearch/bin/plugin -i com.floragunn/search-guard/0.5

sleep 30; kill `cat /var/run/elasticsearch/elasticsearch.pid`
