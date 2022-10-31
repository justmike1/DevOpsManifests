{{- define "parent-app-chart.configmaptemplate" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Chart.Name }}-configmap
{{- with .Values.global.data }}
data:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
