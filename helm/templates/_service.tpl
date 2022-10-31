{{- define "parent-app-chart.servicetemplate" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "parent-app-chart.name" . }}
  labels:
    {{- include "parent-app-chart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - protocol: TCP
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      name: {{ include "parent-app-chart.name" . }}
  selector:
    {{- include "parent-app-chart.selectorLabels" . | nindent 4 }}
{{- end }}
