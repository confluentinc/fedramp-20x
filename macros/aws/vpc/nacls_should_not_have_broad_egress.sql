{% macro nacls_should_not_have_broad_egress(framework, check_id) %}
  {{ return(adapter.dispatch('nacls_should_not_have_broad_egress')(framework, check_id)) }}
{% endmacro %}

{% macro default__nacls_should_not_have_broad_egress(framework, check_id) %}{% endmacro %}

{% macro bigquery__nacls_should_not_have_broad_egress(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Network ACLs should not allow 0.0.0.0/0 egress without port restrictions' as title,
    aws_ec2_network_acls.arn as identifier,
    null as metadata,
    case when egress.arn is not null
        then 'fail'
        else 'pass'
    end as status,
    tags
from {{ full_table_name("aws_ec2_network_acls") }}
    left join (
  select arn from {{ ref('aws_compliance__networks_acls_egress_rules') }}
  where (cidr_block = '0.0.0.0/0' or ipv6_cidr_block = '::/0')
  and (port_range_to is null or port_range_from is null)
  group by arn
) egress
on egress.arn = aws_ec2_network_acls.arn
where {{ partition_filter() }}
    {% endmacro %}
