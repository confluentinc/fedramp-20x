{% macro recovery_planning() %}
-- KSI-RPL: Recovery Planning
-- KSI-RPL-01: Define Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO).
({{ rds_instances_should_have_backup_enabled('KSI-RPL-01','1.0') }})
    {{ union() }}
({{ s3_buckets_should_have_backup_vault_configured('KSI-RPL-01','1.1') }})
    {{ union() }}
-- KSI-RPL-02: Develop and maintain a recovery plan that aligns with the defined recovery objectives.
-- KSI-RPL-03: Perform system backups aligned with recovery objectives.
({{ rds_instances_should_have_backup_enabled('KSI-RPL-03','1.0') }})
    {{ union() }}
({{ s3_buckets_should_have_backup_vault_configured('KSI-RPL-03','1.1') }})
-- KSI-RPL-04: Regularly test the capability to recover from incidents and contingencies.

{% endmacro %}

