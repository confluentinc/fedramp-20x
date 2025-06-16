# FedRAMP 20x DBT Models 

These DBT models represent the evaluations Confluent is using to 
assess compliance with the current FedRAMP KSIs.

## Controls / Checks 

### KSI-CNA
A secure cloud service offering will use cloud native architecture and design principles to enforce and enhance the Confidentiality, Integrity and Availability of the system.

#### KSI-CNA-01: Configure ALL information resources to limit inbound and outbound traffic
#### KSI-CNA-02: Design systems to minimize the attack surface and minimize lateral movement if compromised
#### KSI-CNA-03: Use logical networking and related capabilities to enforce traffic flow controls
#### KSI-CNA-04: Use immutable infrastructure with strictly defined functionality and privileges by default
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

#### KSI-PIY-01: Log and monitor system modifications
#### KSI-PIY-02: Execute changes though redeployment of version controlled immutable resources rather than direct modification wherever possible
#### KSI-PIY-03: Implement automated testing and validation of changes prior to deployment
#### KSI-PIY-04: Have a documented change management procedure
#### KSI-PIY-05: Evaluate the risk and potential impact of any change
#### KSI-PIY-06: Evaluate the risk and potential impact of any change
#### KSI-PIY-07: Evaluate the risk and potential impact of any change


