{% macro eks_control_planes_should_log_all_events(framework, check_id) %}
  {{ return(adapter.dispatch('eks_control_planes_should_log_all_events')(framework, check_id)) }}
{% endmacro %}

{% macro default__eks_control_planes_should_log_all_events(framework, check_id) %}{% endmacro %}

{% macro bigquery__eks_control_planes_should_log_all_events(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'EKS Clusters control planes should log all events' as title,
    eks.arn as identifier,
    JSON_OBJECT() as metadata,
    case
        when
            JSON_VALUE(logConfig, '$.Enabled') = 'false'
            or
            ARRAY_LENGTH(JSON_VALUE_ARRAY(logConfig, '$.Types')) != 5
            or NOT ('api' IN UNNEST(JSON_VALUE_ARRAY(logConfig, '$.Types')))
            or NOT ('audit' IN UNNEST(JSON_VALUE_ARRAY(logConfig, '$.Types')))
            or NOT ('authenticator' IN UNNEST(JSON_VALUE_ARRAY(logConfig, '$.Types')))
            or NOT ('controllerManager' IN UNNEST(JSON_VALUE_ARRAY(logConfig, '$.Types')))
            or NOT ('scheduler' IN UNNEST(JSON_VALUE_ARRAY(logConfig, '$.Types')))
             then 'fail'
         else 'pass'
        end as status,
    eks.tags
from {{ full_table_name("aws_eks_clusters") }} eks,
UNNEST(JSON_QUERY_ARRAY(eks.logging, '$.ClusterLogging')) as logConfig
where {{ partition_filter() }}
{% endmacro %}
