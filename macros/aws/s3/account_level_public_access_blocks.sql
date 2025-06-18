{% macro account_level_public_access_blocks(framework, check_id) %}
  {{ return(adapter.dispatch('account_level_public_access_blocks')(framework, check_id)) }}
{% endmacro %}

{% macro default__account_level_public_access_blocks(framework, check_id) %}{% endmacro %}
{% macro bigquery__account_level_public_access_blocks(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'S3 Block Public Access setting should be enabled' as title,
    aws_iam_accounts.account_id,
    aws_iam_accounts.account_id AS resource_id,
    case when
        config_exists is not TRUE
        or block_public_acls is not TRUE
        or block_public_policy is not TRUE
        or ignore_public_acls is not TRUE
        or restrict_public_buckets is not TRUE
    then 'fail' else 'pass' end as status
from
    {{ full_table_name("aws_iam_accounts") }}
left join
    {{ full_table_name("aws_s3_accounts") }} on
        aws_iam_accounts.account_id = aws_s3_accounts.account_id
 and {{ partition_join("aws_iam_accounts", "aws_s3_accounts")}}
where {{ partition_filter("aws_iam_accounts") }}
{% endmacro %}
