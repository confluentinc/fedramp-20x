{% macro policy_and_inventory() %}
-- KSI-PIY: Policy and Inventory
-- KSI-PIY-01: Use authoritative sources to automatically maintain real-time inventories of all information resources.
({{ asset_inventories_should_be_up_to_date('KSI-PIY-01', '1.0') }})
-- KSI-PIY-02: Document the security objectives and requirements for each information resource or set of information resources.
-- KSI-PIY-03: Maintain a vulnerability disclosure program.
    {{ union() }}
({{ confluent_has_vulnerability_disclosure_email('KSI-PIY-03', '1.0') }})
    {{ union() }}
({{ confluent_has_hackerone_subject('KSI-PIY-03', '1.1') }})
-- KSI-PIY-04: Monitor the effectiveness of building security and privacy considerations into the Software Development Lifecycle and aligning with CISA Secure By Design principles.
-- KSI-PIY-05: Document methods used to evaluate information resource implementations.
-- KSI-PIY-06: Monitor the effectiveness of the organization's investments in achieving security objectives.
-- KSI-PIY-07: Document risk management decisions for software supply chain security.
-- KSI-PIY-08: Regularly measure executive support for achieving the organization’s security objectives.

{% endmacro %}

