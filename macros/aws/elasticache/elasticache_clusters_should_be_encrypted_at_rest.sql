{% macro elasticache_clusters_should_be_encrypted_at_rest(framework, check_id) %}
  {{ return(adapter.dispatch('elasticache_clusters_should_be_encrypted_at_rest')(framework, check_id)) }}
{% endmacro %}

{% macro default__elasticache_clusters_should_be_encrypted_at_rest(framework, check_id) %}{% endmacro %}

{% macro bigquery__elasticache_clusters_should_be_encrypted_at_rest(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Elasticache Clusters should be encrypted at rest' as title,
    arn as identifier,
    null as metadata,
    case when at_rest_encryption_enabled = true
        then 'pass'
        else 'fail'
    end as status,
    tags,
from {{ full_table_name("aws_elasticache_clusters") }}
{% endmacro %}