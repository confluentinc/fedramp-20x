{% macro okta_users_require_phishing_resistant_mfa(framework, check_id) %}
  {{ return(adapter.dispatch('okta_users_require_phishing_resistant_mfa')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_users_require_phishing_resistant_mfa(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_users_require_phishing_resistant_mfa(framework, check_id) %}

{% endmacro %}