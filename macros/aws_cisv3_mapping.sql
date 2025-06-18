{% macro aws_cisv3_mapping(framework, check_id, cis_check_id) %}
  {{ return(adapter.dispatch('aws_cisv3_mapping')(framework, check_id, cis_check_id)) }}
{% endmacro %}

{% macro default__aws_cisv3_mapping(framework, check_id, cis_check_id) %}{% endmacro %}

{% macro bigquery__aws_cisv3_mapping(framework, check_id, cis_check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
     title,
    resource_id as identifier,
    null as metadata,
    status,
    JSON_OBJECT() as tags
from {{ ref("aws_compliance__cis_v3_0_0")}}
where check_id = '{{ cis_check_id }}'

  and {{ partition_filter("user") }}
{% endmacro %}
