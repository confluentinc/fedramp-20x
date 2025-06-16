{% macro k8s_workloads_should_be_immutable(framework, check_id) %}
  {{ return(adapter.dispatch('k8s_workloads_should_be_immutable')(framework, check_id)) }}
{% endmacro %}

{% macro default__k8s_workloads_should_be_immutable(framework, check_id) %}{% endmacro %}

{% macro bigquery__k8s_workloads_should_be_immutable(framework, check_id) %}
{% set k8s_deployment_method_labels = var('k8s_deployment_method_labels') %}
WITH coalesced_data AS (
  {%- for table in var('ksi_cna_04_tables') -%}
    select
      name as resource_name,
      namespace as namespace,
      '{{ table }}' as resource_type,
      context as context,
      labels
    from {{ full_table_name(table) }}
    where {{ partition_filter() }}
    {% if not loop.last %} {{ union() }} {% endif %}
  {%- endfor -%}
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Kubernetes workloads should be immutable' as title,
    CONCAT(context, '.', namespace, '.', resource_name) as identifier,
    null as metadata,
    case
        when {%- for check in k8s_deployment_method_labels -%}
            {% if check['operator'] == 'in' %}
            JSON_EXTRACT_SCALAR(labels, "$['{{ check["key"] }}']") IN ({{ to_sql_list(check["values"]) }})
            {% elif check['operator'] == 'exists' %}
            JSON_EXTRACT_SCALAR(labels, "$['{{ check["key"] }}']") IS NOT NULL
            {% endif %}
            {% if not loop.last %} OR {% endif %}
            {%- endfor -%}
        then 'pass'
        else 'fail'
    end as status,
    labels as tags
from coalesced_data

{% endmacro %}