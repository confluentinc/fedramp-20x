{% macro kubernetes_namespaces_should_have_network_policies(framework, check_id) %}
  {{ return(adapter.dispatch('kubernetes_namespaces_should_have_network_policies')(framework, check_id)) }}
{% endmacro %}

{% macro default__kubernetes_namespaces_should_have_network_policies(framework, check_id) %}{% endmacro %}

{% macro bigquery__kubernetes_namespaces_should_have_network_policies(framework, check_id) %}
with namespaces_with_policies as (
    select distinct
        context,
        namespace
    from {{ full_table_name("k8s_networking_network_policies") }}
    where {{ partition_filter() }}
)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Kubernetes namespaces should have network policies for secure communications' as title,
    ns.context,
    ns.name as resource_id,
    case when
        ns.name not in ('kube-system', 'kube-public', 'kube-node-lease', 'default')
        and nwp.namespace is null
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("k8s_core_namespaces") }} ns
left join namespaces_with_policies nwp 
    on ns.context = nwp.context 
    and ns.name = nwp.namespace
where {{ partition_filter("ns") }}
{% endmacro %}
