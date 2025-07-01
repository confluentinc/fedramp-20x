{% macro nacls_should_not_have_broad_ingress(framework, check_id) %}
  {{ return(adapter.dispatch('nacls_should_not_have_broad_ingress')(framework, check_id)) }}
{% endmacro %}

{% macro default__nacls_should_not_have_broad_ingress(framework, check_id) %}{% endmacro %}

{% macro bigquery__nacls_should_not_have_broad_ingress(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Network ACLs should not allow 0.0.0.0/0 ingress without port restrictions' as title,
    nacl.arn as identifier,
    null as metadata,
    case when ingress.arn is not null
        then 'fail'
        else 'pass'
    end as status,
    nacl.tags
from {{ full_table_name("aws_ec2_network_acls") }} as nacl
    left join (
  select arn from {{ ref('aws_compliance__networks_acls_ingress_rules') }}
  where (cidr_block = '0.0.0.0/0' or ipv6_cidr_block = '::/0')
  and (port_range_to is null or port_range_from is null)
  group by arn
) ingress
on ingress.arn = nacl.arn
left join {{ full_table_name("aws_ec2_vpcs") }} as vpc on nacl.vpc_id = vpc.vpc_id and {{ partition_join("nacl", "vpc")}}
where {{ partition_filter("nacl") }}
  and vpc.is_default = false
    {% endmacro %}
