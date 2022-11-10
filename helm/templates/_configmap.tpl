{{- define "helm-test.iconfigmaptemplate" }}
{{- if .Values.configMap.enabled -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "helm-test.name" . }}-configmap
data:
  {{- toYaml .Values.configMap.data | nindent 2 }}
{{- end }}
{{- end }}
