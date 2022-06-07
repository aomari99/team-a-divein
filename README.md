<img src="https://logos-world.net/wp-content/uploads/2021/08/Deloitte-Logo.png" alt="Deloitte Logo" width="100"/>

# Deloitte DiveIn Case Study - Team A


## Wordpress Website on AWS + Terraform

## Content

1. [Request For Proposal](#rfp)
2. [Global Acceptance Criteria](#gac)
3. [Scrum Team Roles](#str)
4. [Technologies and AWS Services](#tar)
5. [Architecture](#ar)
6. [Pipeline](#pl)
7. [Repository Files](#rf)


### Request For Proposal <a name="rfp"></a>
As a Deloitte interest group we want to host our Website in the cloud and use WordPress as CMS. What cloud architecture would your team propose using a PaaS, VMs, Containers or any other cloud service available in the cloud environment of your choice.


### Global acceptance criteria <a name="gac"></a>
* Consider and address security, scalability, reliability, cost & performance efficiency
* All cloud resources have to deployed via pipeline using Terraform
* Terraform code has to be reusable
* Documentation (readme git) & architecture diagrams (ppt or draw.io)


### Scrum Team Roles <a name="str"></a>
- 1 Scrum Master: Bastian Badde.
- 1 Responsible for Security and Compliance: Bastian Badde.
- 4 DevSecOps: Bastian Badde, Adam Omari, Thanh Ha Dinh, and Alberto Ranz.
- 1 Product Owner: Minh Tamara Tran.


### Technologies and AWS Services <a name="tar"></a>
We used the following technologies for our application: Terraform (Infrastructure as Code), Wordpress (website content management system), Azure Pipelines (CI/CD tool), GitHub (version control), AWS (cloud provider).
We used the following AWS Services: VPC, ECS + Fargate, Application Load Balancer, S3, and RDS.


### Architecture <a name="ar"></a>
Our solution runs on ECS Fargate, a serverless container deployment service. It is connected to an RDS SQL database with Multi-AZ, which automatically creates a standby database instance for failover in another AZ. The database resides in a private subnet. 
In front of the Fargate cluster we got an ALB (application load balancer) facing the internet, which provides a DNS name to the application, and can also serve as an extra layer of security between the Internet Gateway and the instance. 


### Pipeline <a name="pl"></a>
We use Terraform for coding the application infrastructure. The code is stored in a GitHub repo, from where it's pulled to Azure DevOps, which then deploys the application in AWS. Whenever there is a new commit in the GitHub repo, Azure Pipeline automatically gets triggered and checks if it needs to deploy changes to AWS. In case it does, it deploys those changes automatically.


### Repository Files <a name="rf"></a>
- main.tf: contains the main terraform code.
- 
