{% macro rds_instances_should_use_customer_managed_kms_keys(framework, check_id) %}
  {{ return(adapter.dispatch('rds_instances_should_use_customer_managed_kms_keys')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instances_should_use_customer_managed_kms_keys(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instances_should_use_customer_managed_kms_keys(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'RDS instances should use customer-managed KMS keys for encryption' as title,
    arn as identifier,
    JSON_OBJECT(
        'db_instance_identifier', db_instance_identifier,
        'engine', engine,
        'storage_encrypted', storage_encrypted,
        'kms_key_id', kms_key_id,
        'region', region
    ) as metadata,
    case
        when not storage_encrypted then 'fail'
        when kms_key_id is null then 'fail'
        when kms_key_id like '%alias/aws/rds%' then 'fail'
        when kms_key_id like '%:key/%' then 'pass'
        else 'fail'
    end as status,
    tags as tags
from {{ full_table_name("aws_rds_instances") }}
where {{ partition_filter() }}
{% endmacro %}
