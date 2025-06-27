{% macro kms_publicly_accessible(framework, check_id) %}
  {{ return(adapter.dispatch('kms_publicly_accessible')(framework, check_id)) }}
{% endmacro %}

{% macro default__kms_publicly_accessible(framework, check_id) %}{% endmacro %}

{% macro bigquery__kms_publicly_accessible(framework, check_id) %}
with
    project_policy_roles as (
        select project_id, JSON_EXTRACT_ARRAY(bindings) as binding_array
        from {{ full_table_name("gcp_resourcemanager_project_policies") }}
        where {{ partition_filter() }}
    ),
    role_members as (
        select
            project_id,
            binding,
            JSON_VALUE(binding, '$.role') as role,
            JSON_EXTRACT_STRING_ARRAY(binding, '$.members') as member
         from project_policy_roles,
          UNNEST(binding_array) AS binding
    )
select
        ARRAY_TO_STRING(member, ', ') resource_id,
        '{{framework}}' as framework,
        '{{check_id}}' as check_id,
        'Ensure that Cloud KMS cryptokeys are not anonymously or publicly accessible (Automated)'
        as title,
        project_id as project_id,
        case
            when "member" like '%allUsers%' or "member" like '%allAuthenticatedUsers%'
            then 'fail'
            else 'pass'
        end as status
    from role_members
{% endmacro %}