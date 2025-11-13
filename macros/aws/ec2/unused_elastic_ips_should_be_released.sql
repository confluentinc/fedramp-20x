{% macro unused_elastic_ips_should_be_released(framework, check_id) %}
  {{ return(adapter.dispatch('unused_elastic_ips_should_be_released')(framework, check_id)) }}
{% endmacro %}

{% macro default__unused_elastic_ips_should_be_released(framework, check_id) %}{% endmacro %}

{% macro bigquery__unused_elastic_ips_should_be_released(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Elastic IP addresses should be associated with instances' as title,
    arn as identifier,
    JSON_OBJECT() as metadata,
    case when
        instance_id is null
        and network_interface_id is null
        then 'fail'
        else 'pass'
    end as status,
    tags
from {{ full_table_name("aws_ec2_eips") }}
where {{ partition_filter() }}
{% endmacro %}
