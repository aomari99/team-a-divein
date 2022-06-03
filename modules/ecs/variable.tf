variable "secrets_manager_name" {
  description = "Name of the secrets manager secret"
  type        = string
  default     = "wordpress"
}
variable "tags" {
  description = "Map of tags to provide to the resources created"
  type        = map(string)
  default     = {}
}
variable "ecs_cluster_name" {
  description = "Name for the ECS cluster"
  type        = string
  default     = "wordpress_cluster"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "192.168.0.0/16"
}
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  default     = ["192.168.0.0/24", "192.168.1.0/24"]
}

# variable "private_subnet_cidrs" {
#   description = "List of CIDR blocks for private subnets"
#   default     = ["192.168.100.0/24", "192.168.101.0/24", "192.168.102.0/24"]
# }


variable "ecs_task_definition_family" {
  description = "Specify a family for a task definition, which allows you to track multiple versions of the same task definition"
  type        = string
  default     = "wordpress-family"
}

variable "ecs_task_definition_cpu" {
  description = "Number of CPU units reserved for the container in powers of 2"
  type        = string
  default     = "1024"
}

variable "ecs_task_definition_memory" {
  description = "Specify a family for a task definition, which allows you to track multiple versions of the same task definition"
  type        = string
  default     = "2048"
}

variable "db_master_username" {
  description = "Master username of the db"
}
variable "db_master_password" {
  description = "Master password of the db"
}

variable "ecs_service_name" {
  description = "Name for the ECS Service"
  type        = string
  default     = "wordpress"
}

variable "ecs_service_desired_count" {
  description = "The number of instances of fargate tasks to keep running"
  type        = number
  default     = 1
}