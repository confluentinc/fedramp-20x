{% macro load_balancers_have_cloud_armor_policies(framework, check_id) %}
  {{ return(adapter.dispatch('load_balancers_have_cloud_armor_policies')(framework, check_id)) }}
{% endmacro %}

{% macro default__load_balancers_have_cloud_armor_policies(framework, check_id) %}{% endmacro %}

{% macro bigquery__load_balancers_have_cloud_armor_policies(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'GCP Load Balancers have attached Cloud Armor policies' as title,
    lbs.self_link as identifier,
    JSON_OBJECT() as metadata,
    case when
        (policies.self_link IS NOT NULL AND policies.type = 'CLOUD_ARMOR' AND ARRAY_LENGTH(JSON_EXTRACT_ARRAY(rules)) != 0)
         then 'pass'
         else 'fail'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("gcp_compute_backend_services") }} lbs
left join {{ full_table_name("gcp_compute_security_policies") }} policies
    on lbs.security_policy = policies.self_link
    and {{ partition_join("lbs", "policies") }}
WHERE {{ partition_filter("lbs") }}
{% endmacro %}