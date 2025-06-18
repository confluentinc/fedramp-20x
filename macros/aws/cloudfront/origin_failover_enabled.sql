{% macro origin_failover_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('origin_failover_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__origin_failover_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__origin_failover_enabled(framework, check_id) %}
with origin_groups as (
select acd.arn, distribution_config.OriginGroups.Items as ogs
from {{ full_table_name("aws_cloudfront_distributions") }} acd
where {{ partition_filter("acd") }}
),
     oids as (
select distinct
    account_id,
    acd.arn as resource_id,
    case
            when JSON_VALUE(o.ogs) = 'null' or
            JSON_VALUE(o.ogs.Members.Items) = 'null' or
            ARRAY_LENGTH(JSON_QUERY_ARRAY(o.ogs.Members.Items)) = 0  then 'fail'
    else 'pass'
    end as status
from {{ full_table_name("aws_cloudfront_distributions") }} acd
    left join origin_groups o on o.arn = acd.arn
where {{ partition_filter("acd") }}
)
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'CloudFront distributions should have origin failover configured' as title,
    account_id,
    resource_id,
    status
from oids
{% endmacro %}
