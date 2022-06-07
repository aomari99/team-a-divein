# team-a-divein

# DELOITTE DIVEIN CASE STUDY

## Wordpress Website on AWS + Terraform

### Requirements List

#### RFP
As a Deloitte interest group we want to host our Website in the cloud and use WordPress as CMS. What cloud architecture would your team propose using a PaaS, VMs, Containers or any other cloud service available in the cloud environment of your choice.

#### Global acceptance criteria
* Consider and address security, scalability, reliability, cost & performance efficiency
* All cloud resources have to deployed via pipeline using Terraform
* Terraform code has to be reusable
* Documentation (readme git) & architecture diagrams (ppt or draw.io)

#### Scrum Team Roles
- 1 Scrum Master: Bastian Badde
- 1 Responsible for Security and Compliance: Bastian Badde
- 4 DevSecOps: Bastian Badde, Adam Omari, Thanh Ha Dinh, and Alberto Ranz
- 1 Product Owner: Minh Tamara Tran

### Architecture
Our solution runs on ECS Fargate, a serverless container deployment service. It is connected to an RDS SQL database with Multi-AZ, which automatically creates a standby database instance for failover in another AZ. The database resides in a private subnet. 
In front of the Fargate cluster, we got an ALB (application load balancer) facing the internet, which provides a DNS name to the application, and can also serve as an extra layer of security. 

### Pipeline
We use Terraform for the application infrastructure. The code is stored in a GitHub repo, from where it's pulled to Azure DevOps, which then deploys the application in AWS. Whenever there is a change in the GitHub repo, Azure DevOps automatically detects it and deploys the application again to AWS.
