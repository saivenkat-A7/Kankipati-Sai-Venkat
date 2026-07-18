{{/* Common name helper */}}
{{- define "saas-chart.fullname" -}}
{{ .Release.Name }}
{{- end -}}
