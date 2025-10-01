{% macro ebs_volumes_should_be_encrypted_by_default(framework, check_id) %}
  {{ return(adapter.dispatch('ebs_volumes_should_be_encrypted_by_default')(framework, check_id)) }}
{% endmacro %}

{% macro default__ebs_volumes_should_be_encrypted_by_default(framework, check_id) %}{% endmacro %}

{% macro bigquery__ebs_volumes_should_be_encrypted_by_default(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'EBS Volumes should be encrypted by default' as title,
    CONCAT(account_id, '-', region) as identifier,
    JSON_OBJECT() as metadata,
    case when ebs_encryption_by_default = true
        then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("aws_ebs_encryption_by_defaults") }}
WHERE {{ partition_filter() }}
    {% endmacro %}