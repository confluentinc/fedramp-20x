{% macro jira_should_have_change_management_project(framework, check_id) %}
  {{ return(adapter.dispatch('jira_should_have_change_management_project')(framework, check_id)) }}
{% endmacro %}

{% macro default__jira_should_have_change_management_project(framework, check_id) %}{% endmacro %}

{% macro bigquery__jira_should_have_change_management_project(framework, check_id) %}
{{ verify_jira_project_exists(framework, check_id, 'Change Management', var('change_management_jira_project') )}}
{% endmacro %}