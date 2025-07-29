{% macro instances_reachable_with_public_ip() %}
  {{ return(adapter.dispatch('instances_reachable_with_public_ip')()) }}
{% endmacro %}

{% macro default__instances_reachable_with_public_ip() %}{% endmacro %}

{% macro bigquery__instances_reachable_with_public_ip() %}
SELECT
    'EC2 Instances with a public IP address' as title,
    account_id,
    arn AS resource_id,
    'aws_ec2_instances' as resource_type,
    'instance_with_public_ip' as reachability_type,
    public_ip_address as endpoint,
    'ip_address' as endpoint_type
FROM
    {{ full_table_name("aws_ec2_instances") }}
WHERE {{ partition_filter() }}
AND public_ip_address IS NOT NULL
    {% endmacro %}
