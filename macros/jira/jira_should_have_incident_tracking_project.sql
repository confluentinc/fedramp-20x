{% macro jira_should_have_incident_tracking_project(framework, check_id) %}
  {{ return(adapter.dispatch('jira_should_have_incident_tracking_project')(framework, check_id)) }}
{% endmacro %}

{% macro default__jira_should_have_incident_tracking_project(framework, check_id) %}{% endmacro %}

{% macro bigquery__jira_should_have_incident_tracking_project(framework, check_id) %}
{{ verify_jira_project_exists(framework, check_id, 'Service Incident Tracking', var('incident_tracking_jira_project') )}}
{% endmacro %}