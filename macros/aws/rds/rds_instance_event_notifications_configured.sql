{% macro rds_instance_event_notifications_configured(framework, check_id) %}
  {{ return(adapter.dispatch('rds_instance_event_notifications_configured')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instance_event_notifications_configured(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instance_event_notifications_configured(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'An RDS event notifications subscription should be configured for critical database instance events' as title,
    account_id,
    SOURCE_ARN AS resource_id,
    CASE 
        WHEN   
            'maintenance' IN UNNEST(EVENT_CATEGORIES) AND
            'configuration' IN UNNEST(EVENT_CATEGORIES) AND
            'failure' IN UNNEST(EVENT_CATEGORIES) 
            THEN 'pass'
        ELSE 'fail'
    END AS status
FROM
    {{ full_table_name("aws_rds_events") }}
WHERE
    source_type = 'db-instance'
and {{ partition_filter() }}
{% endmacro %}
