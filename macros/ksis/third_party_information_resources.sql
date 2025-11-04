{% macro third_party_information_resources() %}
-- KSI-TPR: Third-Party Information Resources
-- KSI-TPR-01: Follow the requirements and recommendations in the FedRAMP Minimum Assessment Standard regarding third-party information resources
({{ vendors_should_have_fedramp_authorization('KSI-TPR-01', '1.0') }})

-- KSI-TPR-03: Identify and prioritize mitigation of potential supply chain risks.
-- KSI-TPR-04: Monitor third party software information resources for upstream vulnerabilities, with contractual notification requirements or active monitoring services.
{% endmacro %}

