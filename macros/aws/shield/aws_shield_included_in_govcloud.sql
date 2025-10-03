{% macro aws_shield_included_in_govcloud(framework, check_id) %}
  {{ return(adapter.dispatch('aws_shield_included_in_govcloud')(framework, check_id)) }}
{% endmacro %}

{% macro default__aws_shield_included_in_govcloud(framework, check_id) %}{% endmacro %}

{% macro bigquery__aws_shield_included_in_govcloud(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'AWS Shield (Standard) is active on GovCloud accounts' as title,
    id as identifier,
    JSON_OBJECT() as metadata,
    case when CONTAINS_SUBSTR(arn, "aws-us-gov") then 'pass' else 'fail' end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("aws_organizations_accounts") }}
where _cq_source_name = 'aws-root-account-govcloud'
and {{ partition_filter() }}
    {% endmacro %}
