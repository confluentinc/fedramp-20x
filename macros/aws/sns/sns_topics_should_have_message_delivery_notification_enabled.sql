{% macro sns_topics_should_have_message_delivery_notification_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('sns_topics_should_have_message_delivery_notification_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__sns_topics_should_have_message_delivery_notification_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__sns_topics_should_have_message_delivery_notification_enabled(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Logging of delivery status should be enabled for notification messages sent to a topic' as title,
    account_id,
    arn as resource_id,
    case when
        unknown_fields.HTTPSuccessFeedbackRoleArn IS NULL
        AND  unknown_fields.FirehoseSuccessFeedbackRoleArn IS NULL
        AND  unknown_fields.LambdaSuccessFeedbackRoleArn IS NULL
        AND  unknown_fields.ApplicationSuccessFeedbackRoleArn IS NULL
        AND  unknown_fields.SQSSuccessFeedbackRoleArn IS NULL
    then 'fail' else 'pass' end as status
FROM {{ full_table_name("aws_sns_topics") }}
where {{ partition_filter() }}
{% endmacro %}
