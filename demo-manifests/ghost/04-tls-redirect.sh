#!/bin/bash -e

cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ghost-blog
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    cert-manager.io/cluster-issuer: letsencrypt
    cert-manager.io/acme-challenge-type: http01
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - blog.demo.azure.boxboat.io
    secretName: ghost-blog
  rules:
  - host: blog.demo.azure.boxboat.io
    http:
      paths:
      - backend:
          serviceName: ghost-blog
          servicePort: 2368
        path: /
        pathType: Prefix
EOF

kubectl set env deployment ghost-blog url=https://blog.demo.azure.boxboat.io

