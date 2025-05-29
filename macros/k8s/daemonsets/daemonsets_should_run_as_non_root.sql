{% macro daemonsets_should_run_as_non_root(framework, check_id) %}
  {{ return(adapter.dispatch('daemonsets_should_run_as_non_root')(framework, check_id)) }}
{% endmacro %}

{% macro default__daemonsets_should_run_as_non_root(framework, check_id) %}{% endmacro %}

{% macro bigquery__daemonsets_should_run_as_non_root(framework, check_id) %}
(
     select
        '{{ framework }}' as framework,
        '{{ check_id }}' as check_id,
        'Daemonset containers should run as non-root' as title,
        CONCAT('cluster:', context, ':namespace:', namespace, ':name:', name, ':container:', JSON_VALUE(container, '$.name')) as identifier,
        NULL as metadata,
        CASE WHEN BOOL(JSON_QUERY(container, '$.securityContext.runAsNonRoot')) IS DISTINCT FROM true
            THEN 'fail'
            ELSE 'pass'
        END as status
    from {{ full_table_name("k8s_apps_daemon_sets") }},
    UNNEST(JSON_EXTRACT_ARRAY(spec_template, '$.spec.containers')) as container
)

{{ union() }}

(
    select
        '{{ framework }}' as framework,
        '{{ check_id }}' as check_id,
        'Daemonset initContainers should run as non-root' as title,
        CONCAT('cluster:', context, ':namespace:', namespace, ':name:', name, ':container:', JSON_VALUE(initContainer, '$.name')) as identifier,
        NULL as metadata,
        CASE WHEN BOOL(JSON_QUERY(initContainer, '$.securityContext.runAsNonRoot')) IS DISTINCT FROM true
            THEN 'fail'
            ELSE 'pass'
        END as status
    from {{ full_table_name("k8s_apps_daemon_sets") }},
     UNNEST(JSON_EXTRACT_ARRAY(spec_template, '$.spec.initContainers')) as initContainer
)
{% endmacro %}
