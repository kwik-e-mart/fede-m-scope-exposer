apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: vs-{{ .service.slug }}-{{ .service.id }}-public
  namespace: {{ .k8s_namespace }}
  labels:
    nullplatform: "true"
    service: {{ .service.slug }}
    service_id: {{ .service.id }}
spec:
  hosts:
    - {{ .parameters.domain }}
  gateways:
    - istio-ingress/api-gateway
  http:
    - match:
        - uri:
            prefix: /
      fault:
        abort:
          percentage:
            value: 100
          httpStatus: 404
      route:
        - destination:
            host: response-404.{{ .k8s_namespace }}.svc.cluster.local
            port:
              number: 80