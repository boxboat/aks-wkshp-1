#!/bin/bash -e

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: info@your-org.com
    privateKeySecretRef:
      name: letsencrypt
    solvers:
    - http01:
        ingress:
          class: azure/application-gateway
          podTemplate:
            spec:
              nodeSelector:
                "kubernetes.io/os": linux
EOF

cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ghost-blog
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    cert-manager.io/cluster-issuer: letsencrypt
    cert-manager.io/acme-challenge-type: http01
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

#kubectl set env deployment ghost-blog url=https://blog.demo.azure.boxboat.io

