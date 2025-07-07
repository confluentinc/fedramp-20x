{% macro jira_should_have_continuous_monitoring_project(framework, check_id) %}
  {{ return(adapter.dispatch('jira_should_have_continuous_monitoring_project')(framework, check_id)) }}
{% endmacro %}

{% macro default__jira_should_have_continuous_monitoring_project(framework, check_id) %}{% endmacro %}

{% macro bigquery__jira_should_have_continuous_monitoring_project(framework, check_id) %}
{{ verify_jira_project_exists(framework, check_id, 'Vulnerability Remediation', var('continuous_monitoring_jira_project') )}}
{% endmacro %}