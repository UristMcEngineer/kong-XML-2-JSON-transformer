# kong XML 2 JSON transformer

updated XML to JSON custom plugin for Kong 3.4.0 on k8s.

Forked from: https://github.com/Saeed-AlRafi/kong-XML-2-JSON-transformer

## What:
This plugin will convert XML objects from upstream and convert them to JSON before sending them downstream.

## How:
The plugin starts by checking the "Content-Type" header. if it is "application/xml" then it will change it to "application/json" and proceed with converting the body.

## Setup:

Create a ConfigMap with the Lua code of the plugin by applying the supplied `ConfigMap.yaml`.

Build a custom container image for the proxy-kong Deployment by using the supplied `Dockerfile` and push it to a container repository accessible from your cluster.
This is one way to supply the necessary dependencies to the plugin Lua code.

To install the plugin, first modify the Deployment "kong-proxy" to use your custom image you created in the last step and to mount the Lua code from your ConfigMap:
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

Now the Plugin can be defined as a KongPlugin or KongClusterPlugin and then applied to Ingresses or Services just like official plugins:
```yaml
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: xml-2-json-transformer
  namespace: business-logic
plugin: xml-2-json-transformer
–––
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: xml-api-unchanged
  namespace: business-logic
  annotations:
    konghq.com/strip-path: 'true'
    konghq.com/plugins: xml-2-json-transformer
spec:
  ingressClassName: kong
  rules:
    - http:
        paths:
          - path: '/xml-api'
            pathType: Prefix
            backend:
              service:
                name: xml-api
                port:
                  number: 18080
```