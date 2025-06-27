{% macro kms_separation_of_duties(framework, check_id) %}
  {{ return(adapter.dispatch('kms_separation_of_duties')(framework, check_id)) }}
{% endmacro %}

{% macro default__kms_separation_of_duties(framework, check_id) %}{% endmacro %}

{% macro bigquery__kms_separation_of_duties(framework, check_id) %}
 with
    project_policy_roles as (
        select project_id,
        binding as binding
        from {{ full_table_name("gcp_resourcemanager_project_policies") }},
        UNNEST(JSON_QUERY_ARRAY(bindings)) AS binding
        where {{ partition_filter() }}
    ),
    role_members as (
        select
            project_id,
            binding.role as role,
            member as member
        from project_policy_roles,
        UNNEST(JSON_QUERY_ARRAY(binding.members)) AS member
    ),
    member_with_roles as (
        select project_id, JSON_VALUE(member) as member, array_agg(JSON_VALUE(role)) as roles
        from role_members
        group by JSON_VALUE(member), project_id
    )
select
        member as resource_id,
        '{{framework}}' as framework,
        '{{check_id}}' as check_id,
        'Ensure that Separation of duties is enforced while assigning KMS related roles to users (Automated)'
        as title,
        project_id as project_id,
        case
            when
                member like 'user:%'
                AND 'roles/cloudkms.admin' IN UNNEST(roles)
                AND ('roles/cloudkms.cryptoKeyEncrypterDecrypter' IN UNNEST(roles)
                    OR 'roles/cloudkms.cryptoKeyEncrypter' IN UNNEST(roles)
                    OR 'roles/cloudkms.cryptoKeyDecrypter' IN UNNEST(roles))
            then 'fail'
            else 'pass'
        end as status
    from member_with_roles
{% endmacro %}