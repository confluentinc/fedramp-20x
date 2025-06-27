{% macro iam_service_account_admin_priv(framework, check_id) %}
  {{ return(adapter.dispatch('iam_service_account_admin_priv')(framework, check_id)) }}
{% endmacro %}

{% macro default__iam_service_account_admin_priv(framework, check_id) %}{% endmacro %}

{% macro bigquery__iam_service_account_admin_priv(framework, check_id) %}
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
        'Ensure that Service Account has no Admin privileges (Automated)' as title,
        project_id as project_id,
        case
            when
                (
                    "role" in ('roles/editor', 'roles/owner')
                    or "role" LIKE ANY ('%Admin', '%admin')
                )
                and "member" like 'serviceAccount:%.iam.gserviceaccount.com'
            then 'fail'
            else 'pass'
        end as status
    from role_members
{% endmacro %}