{{ $all_config := "monitoring/containers/all" -}}
{{- if (keyExists $all_config) -}}
{{- range $key := key $all_config | split "\n" -}}
{{ $config := (printf "monitoring/configs/%s" $key) -}}
{{- if (keyExists $config) -}}
## From config "{{ $config }}"
{{ key $config }}
{{ end }}
{{ end }}
{{- end -}}

{{ $container_config := (printf "monitoring/containers/%s" (env "CONTAINER")) -}}
{{- if (keyExists $container_config) -}}
{{- range $key := key $container_config | split "\n" -}}
{{- $config := (printf "monitoring/configs/%s" $key) -}}
{{- if (keyExists $config) -}}
## From config "{{ $config }}"
{{ key $config }}
{{ end }}
{{ end }}
{{- end -}}

# Needed to stay safe against empty configuration
[[inputs.swap]]
[[outputs.file]]
  files = ["/dev/null"]
