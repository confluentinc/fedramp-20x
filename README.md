# FedRAMP 20x DBT Models 

These DBT models represent the evaluations Confluent is using to 
assess compliance with the current FedRAMP KSIs.

## Controls / Checks 

### KSI-CNA
A secure cloud service offering will use cloud native architecture and design principles to enforce and enhance the Confidentiality, Integrity and Availability of the system.

#### KSI-CNA-01: Configure ALL information resources to limit inbound and outbound traffic
- (AWS) RDS instances are not publicly accessible 
- (AWS) ALBs restrict access to limited port ranges 
- (AWS) Default security groups have no access 

#### KSI-CNA-02: Design systems to minimize the attack surface and minimize lateral movement if compromised
- (AWS) Security groups have restricted ingress and egress rules
- (AWS) Network ACLs have restricted ingress and egress rules

#### KSI-CNA-03: Use logical networking and related capabilities to enforce traffic flow controls
- (AWS) Security groups have restricted ingress and egress rules
- (AWS) Network ACLs have restricted ingress and egress rules

#### KSI-CNA-04: Use immutable infrastructure with strictly defined functionality and privileges by default
- (Kubernetes) Images use immutable tags instead of aliases, such as `latest`
- (Kubernetes) Workloads are deployed through immutable tools
- (Kubernetes) Images use allowed internal registries

#### KSI-CNA-05: Have denial of service protection
#### KSI-CNA-06: Design systems for high availability and rapid recovery
#### KSI-CNA-07: Ensure cloud-native information resources are implemented based on host provider’s best practices and documented guidance

### KSI-SVC
A secure cloud service offering will follow FedRAMP encryption policies, continuously verify information resource integrity, and restrict access to third-party information resources.

#### KSI-SVC-01: Harden and review network and system configurations
#### KSI-SVC-02: Encrypt or otherwise secure network traffic
#### KSI-SVC-03: Encrypt all federal and sensitive information at rest
#### KSI-SVC-04: Manage configuration centrally
#### KSI-SVC-05: Enforce system and information resource integrity through cryptographic means
#### KSI-SVC-06: Use automated key management systems to manage, protect, and regularly rotate digital keys and certificate
#### KSI-SVC-07: Use a consistent, risk-informed approach for applying security patches

### KSI-IAM
A secure cloud service offering will protect user data, control access, and apply zero trust principles

#### KSI-IAM-01: Enforce multi-factor authentication (MFA) using methods that are difficult to intercept or impersonate (phishing-resistant MFA) for all user authentication
#### KSI-IAM-02: Use secure passwordless methods for user authentication and authorization when feasible, otherwise enforce strong passwords with MFA
#### KSI-IAM-03: Enforce appropriately secure authentication methods for non-user accounts and services
#### KSI-IAM-04: Use a least-privileged, role and attribute-based, and just-in-time security authorization model for all user and non-user accounts and services
#### KSI-IAM-05: Apply zero trust design principles
#### KSI-IAM-06: Automatically disable or otherwise secure accounts with privileged access in response to suspicious activity

### KSI-MLA
A secure cloud service offering will monitor, log, and audit all important events, activity, and changes

#### KSI-MLA-01: Operate a Security Information and Event Management (SIEM) or similar system(s) for centralized, tamper-resistent logging of events, activities, and changes
#### KSI-MLA-02: Regularly review and audit logs
#### KSI-MLA-03: Rapidly detect and remediate or mitigate vulnerabilities
#### KSI-MLA-04: Perform authenticated vulnerability scanning on information resources
#### KSI-MLA-05: Perform Infrastructure as Code and configuration evaluation and testing
#### KSI-MLA-06: Centrally track and prioritize the mitigation and/or remediation of identified vulnerabilities

### KSI-CMT
A secure cloud service provider will ensure that all system changes are properly documented and configuration baselines are updated accordingly

#### KSI-CMT-01: Log and monitor system modifications
#### KSI-CMT-02: Execute changes though redeployment of version controlled immutable resources rather than direct modification wherever possible
#### KSI-CMT-03: Implement automated testing and validation of changes prior to deployment
#### KSI-CMT-04: Have a documented change management procedure
#### KSI-CMT-05: Evaluate the risk and potential impact of any change

### KSI-PIY
A secure cloud service offering will have intentional, organized, universal guidance for how every information resource, including personnel, is secured

#### KSI-PIY-01: Have an up-to-date information resource inventory or code defining all deployed assets, software, and services.
#### KSI-PIY-02: Have policies outlining the security objectives of all information resources.
#### KSI-PIY-03: Maintain a vulnerability disclosure program.
#### KSI-PIY-04: Build security considerations into the Software Development Lifecycle and align with CISA Secure By Design principles.
#### KSI-PIY-05: Document methods used to evaluate information resource implementations.
#### KSI-PIY-06: Have a dedicated staff and budget for security with executive support, commensurate with the size, complexity, scope, and risk of the service offering.
#### KSI-PIY-07: Document risk management decisions for software supply chain security.

### KSI-TPR 
A secure cloud service offering will understand, monitor, and manage supply chain risks from third-party information resources.

#### KSI-TPR-01: Identify all third-party information resources .
#### KSI-TPR-02: Regularly confirm that services handling federal information or are likely to impact the confidentiality, integrity, or availability of federal information are FedRAMP authorized and securely configured.
#### KSI-TPR-03: Identify and prioritize mitigation of potential supply chain risks.
#### KSI-TPR-04: Monitor third party software information resources for upstream vulnerabilities, with contractual notification requirements or active monitoring services.

### KSI-CED
A secure cloud service provider will continuously educate their employees on cybersecurity measures, testing them regularly to ensure their knowledge is satisfactory.

#### KSI-CED-01: Ensure all employees receive security awareness training.
#### KSI-CED-02: Require role-specific training for high risk roles, including at least roles with privileged access.

### KSI-RPL 
A secure cloud service offering will define, maintain, and test incident response plan(s) and recovery capabilities to ensure minimal service disruption and data loss during incidents and contingencies.

#### KSI-RPL-01: Define Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO).
#### KSI-RPL-02: Develop and maintain a recovery plan that aligns with the defined recovery objectives.
#### KSI-RPL-03: Perform system backups aligned with recovery objectives.
#### KSI-RPL-04: Regularly test the capability to recover from incidents and contingencies.

### KSI-INR
A secure cloud service offering will document, report, and analyze security incidents to ensure regulatory compliance and continuous security improvement.

#### KSI-INR-01: Report incidents according to FedRAMP requirements and cloud service provider policies.
#### KSI-INR-02: Maintain a log of incidents and periodically review past incidents for patterns or vulnerabilities.
#### KSI-INR-03: Generate after action reports and regularly incorporate lessons learned into operations.
