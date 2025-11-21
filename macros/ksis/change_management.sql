{% macro change_management() %}
-- KSI-CMT: Change Management
-- KSI-CMT-01: Log and monitor modifications to the cloud service offering.
({{ organization_cloudtrail_should_emit_events_to_s3('KSI-CMT-01', '1.0') }})
    {{ union() }}
({{ eks_control_planes_should_log_all_events('KSI-CMT-01', '1.1') }})
    {{ union() }}
-- KSI-CMT-02: Execute changes though redeployment of version controlled immutable resources rather than direct modification wherever possible
-- KSI-CMT-03: Automate persistent testing and validation of changes throughout deployment.
-- KSI-CMT-04: Always follow a documented change management procedure.

{% endmacro %}

