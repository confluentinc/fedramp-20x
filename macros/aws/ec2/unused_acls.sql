{% macro unused_acls(framework, check_id) %}
  {{ return(adapter.dispatch('unused_acls')(framework, check_id)) }}
{% endmacro %}

{% macro default__unused_acls(framework, check_id) %}{% endmacro %}

{% macro bigquery__unused_acls(framework, check_id) %}
with results as (
select distinct
    account_id,
    network_acl_id as resource_id,
    case when
        association.NetworkAclAssociationId is null
        then 'pass'
        else 'fail'
    end as status
from {{ full_table_name("aws_ec2_network_acls") }},
UNNEST(JSON_QUERY_ARRAY(associations)) AS association
where {{ partition_filter("aws_ec2_network_acls") }}
)
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Unused network access control lists should be removed' as title,
    account_id,
    resource_id,
    status
from results
{% endmacro %}
