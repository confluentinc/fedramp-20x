{% macro redis_replication_groups_should_be_encrypted_in_transit(framework, check_id) %}
  {{ return(adapter.dispatch('redis_replication_groups_should_be_encrypted_in_transit')(framework, check_id)) }}
{% endmacro %}

{% macro default__redis_replication_groups_should_be_encrypted_in_transit(framework, check_id) %}{% endmacro %}

{% macro bigquery__redis_replication_groups_should_be_encrypted_in_transit(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'ElastiCache for Redis replication groups should be encrypted in transit' as title,
    arn as identifier,
    null as metadata,
    CASE
        WHEN transit_encryption_enabled = false OR transit_encryption_enabled IS NULL THEN 'fail'
        ELSE 'pass'
        END as status
FROM
    {{ full_table_name("aws_elasticache_replication_groups") }}
{% endmacro %}