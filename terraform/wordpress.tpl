[
  {

    "environment": [
      {
        "name": "WORDPRESS_DB_USER", 
        "value": "${wordpress_db_user}"
      },
      {
        "name": "WORDPRESS_DB_PASSWORD", 
        "value": "${wordpress_db_password}"
      },

      {
        "name": "WORDPRESS_DB_HOST",
        "value": "${wordpress_db_host}"
      },
      {
        "name": "WORDPRESS_DB_NAME",
        "value": "wordpress"
      }
    ],
    "essential": true,
    "image": "wordpress:latest",        
    "name": "wordpress",
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver":"awslogs",
      "options": {
        "awslogs-group": "${cloudwatch_log_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "app"
      }
    }
  }
]