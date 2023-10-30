# kong XML 2 JSON transformer

updated XML to JSON custom plugin for Kong 3.4.0 on k8s.

Forked from: https://github.com/Saeed-AlRafi/kong-XML-2-JSON-transformer

## What:
This plugin will convert XML objects from upstream and convert them to JSON before sending them downstream.

## How:
The plugin starts by checking the "Content-Type" header. if it is "application/xml" then it will change it to "application/json" and proceed with converting the body.

## Setup:

Set the working directory to the directory this readme is in and execute
```
docker build --tag "image_name"
docker push "image_name"
```
to build the container image using the dockerfile provided to install dependencies for the XML2JSON plugin.

To run the plugin, first modify the Deployment "kong-proxy":
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-kong
  namespace: kong
...
spec:
  template:
    spec:
      containers:
      - name: proxy
        env:
        - name: KONG_PLUGINS
          value: bundled,xml-2-json-transformer
        - name: KONG_LUA_PACKAGE_PATH
          value: "/opt/?.lua;;"
        volumeMounts:
        - mountPath: /opt/kong/plugins/xml-2-json-transformer
          name: plugin-xml-2-json-transformer
    image: YOUR-DOCKER-IMAGE-IN-DOCKERHUB
    ...
      volumes:
      - configMap:
          defaultMode: 420
          name: plugin-xml-2-json-transformer
        name: plugin-xml-2-json-transformer
    ...
```
works alongside the plugins provided by Kong.
