{% macro publicly_readable_buckets(framework, check_id) %}
  {{ return(adapter.dispatch('publicly_readable_buckets')(framework, check_id)) }}
{% endmacro %}

{% macro bigquery__publicly_readable_buckets(framework, check_id) %}
with policy_allow_public as (
    select
        arn,
        count(*) as statement_count
    from
        (
            select
                b.arn,
                bp.policy_json.Statement.Principal as principals
            from
                {{ full_table_name("aws_s3_buckets") }} b
                inner join {{ full_table_name("aws_s3_bucket_policies") }} bp
                on b.arn = bp.bucket_arn
                and {{ partition_join("b", "bp") }}
            where
                JSON_VALUE(bp.policy_json.Statement.Effect) = '"Allow"'
            and {{ partition_filter("b") }}
        ) as foo
    where
        JSON_VALUE(principals) = '"*"'
        or (
            'AWS' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(principals))
            and (
                JSON_VALUE(principals.AWS) = '"*"'
                or '"*"' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(principals.AWS))
            )
        )
    group by
        arn
)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'S3 buckets should prohibit public read access' as title,
    b.account_id,
    b.arn as resource_id,
    'fail' as status -- TODO FIXME
from
    -- Find and join all bucket ACLS that give a public write access
    {{ full_table_name("aws_s3_buckets") }} b
left join
    {{ full_table_name("aws_s3_bucket_grants") }} bg on
        bg._cq_parent_id = b._cq_id
-- Find all statements that could give public allow access 
-- Statements that give public access have 1) Effect == Allow 2) One of the following principal:
--       Principal = {"AWS": "*"}
--       Principal = {"AWS": ["arn:aws:iam::12345678910:root", "*"]}
--       Principal = "*"
left join policy_allow_public on
        b.arn = policy_allow_public.arn
left join {{ full_table_name("aws_s3_bucket_public_access_blocks") }} bpab
        ON bpab._cq_parent_id = b._cq_id
where
    (
        CAST( JSON_VALUE(bpab.public_access_block_configuration.BlockPublicAcls) AS BOOL) != TRUE
        and (
            JSON_VALUE(grantee.URI) = 'http://acs.amazonaws.com/groups/global/AllUsers'
            and permission in ('READ_ACP', 'FULL_CONTROL')
        )
    )
    or (
       CAST( JSON_VALUE(bpab.public_access_block_configuration.BlockPublicPolicy) AS BOOL) != TRUE
        and policy_allow_public.statement_count > 0
    )
{% endmacro %} 
