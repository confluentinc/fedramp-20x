{% macro cluster_publicly_accessible(framework, check_id) %}
  {{ return(adapter.dispatch('cluster_publicly_accessible')(framework, check_id)) }}
{% endmacro %}

{% macro default__cluster_publicly_accessible(framework, check_id) %}{% endmacro %}
         
{% macro bigquery__cluster_publicly_accessible(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Amazon Redshift clusters should prohibit public access' as title,
    account_id,
    arn AS resource_id,
    case when publicly_accessible is TRUE then 'fail' else 'pass' end as status
from {{ full_table_name("aws_redshift_clusters") }}
where {{ partition_filter() }}
{% endmacro %}  
