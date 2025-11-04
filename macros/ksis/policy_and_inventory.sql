{% macro policy_and_inventory() %}
-- KSI-PIY: Policy and Inventory
-- KSI-PIY-01: Generate inventories of information resources from authoritative sources
({{ asset_inventories_should_be_up_to_date('KSI-PIY-01', '1.0') }})
-- KSI-PIY-02: Document the security objectives and requirements for each information resource
-- KSI-PIY-03: Maintain a vulnerability disclosure program.
-- KSI-PIY-04: Build security and privacy considerations into the Software Development Lifecycle and align with CISA Secure By Design principles
-- KSI-PIY-05: Document methods used to evaluate information resource implementations.
-- KSI-PIY-06: Have staff and budget for security commensurate with the size, complexity, scope, executive
-- priorities, and risk of the service offering that demonstrates commitment to delivering a secure service.
-- KSI-PIY-07: Document risk management decisions for software supply chain security.

{% endmacro %}

