{% macro rds_instances_reachable_with_public_ip() %}
  {{ return(adapter.dispatch('rds_instances_reachable_with_public_ip')()) }}
{% endmacro %}

{% macro default__rds_instances_reachable_with_public_ip() %}{% endmacro %}

{% macro bigquery__rds_instances_reachable_with_public_ip() %}
SELECT
    'RDS Instances that are publicly accessible' as title,
    account_id,
    arn AS resource_id,
    'aws_rds_instances' as resource_type,
    'publicly_accessible' as reachability_type,
    NULL as from_port,
    NULL as to_port,
    '' as protocol,
    JSON_EXTRACT_SCALAR(endpoint, "$.Address") as endpoint,
    'dns_name' as endpoint_type
FROM
    {{ full_table_name("aws_rds_instances") }}
WHERE {{ partition_filter() }}
AND publicly_accessible = true
    {% endmacro %}
