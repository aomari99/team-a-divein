
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

variable "ecs_cluster_name" {
  description = "Name for the ECS cluster"
  type        = string
  default     = "wordpress_cluster"
}

variable "log_retention_in_days" {
  description = "The number of days to retain cloudwatch log"
  default     = "1"
}

#lb variables

variable "lb_name" {
  description = "Name for the load balancer"
  type        = string
  default     = "wordpress"
}

variable "lb_internal" {
  description = "If the load balancer should be an internal load balancer"
  type        = bool
  default     = false
}


variable "lb_target_group_http" {
  description = "Name of the HTTP target group"
  type        = string
  default     = "wordpress-http"
}

