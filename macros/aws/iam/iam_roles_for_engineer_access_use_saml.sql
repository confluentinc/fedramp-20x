{% macro iam_roles_for_engineer_access_use_saml(framework, check_id) %}
  {{ return(adapter.dispatch('iam_roles_for_engineer_access_use_saml')(framework, check_id)) }}
{% endmacro %}

{% macro default__iam_roles_for_engineer_access_use_saml(framework, check_id) %}{% endmacro %}

{% macro bigquery__iam_roles_for_engineer_access_use_saml(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'IAM roles for engineer access should use Okta as identity provider' as title,
    arn as identifier,
    JSON_OBJECT() as metadata,
    CASE
        WHEN (
            SELECT 1 FROM UNNEST(JSON_QUERY_ARRAY(assume_role_policy_document, '$.Statement')) AS stmt
            WHERE JSON_VALUE(stmt, '$.Effect') = 'Allow'
            AND JSON_VALUE(stmt, '$.Condition.StringEquals."SAML:aud"') is not null
            LIMIT 1
            ) = 1
        THEN 'pass'
        ELSE 'fail'
    END as status,
    tags
FROM {{ full_table_name("aws_iam_roles" )}} as roles
LEFT JOIN UNNEST(JSON_VALUE_ARRAY(assume_role_policy_document, '$.Statement')) AS stmt
WHERE (role_name like '%prod-reader%' OR role_name like '%prod-administrator%')
AND {{ partition_filter() }}
{% endmacro %}


