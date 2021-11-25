variable "region" {
  description = "This is the cloud hosting region where your webapp will be deployed."
}

variable "dev_prefix" {
  description = "This is the environment where your webapp is deployed. qa, prod, or dev"
}

variable "vpc_name"{
  description = "This is the vpc where dev environment is deployed"
}

variable "vpc_cidr"{
  description = "CIDR for vpc"
}

variable "project_name"{
  description = "Name of preject to which these resources belong"
}

variable "subnet_1_name"{
  description = "Name of first public subnet"
}

variable "subnet_1_cidr"{
  description = "CIDR for  first public subnet"
}

variable "subnet_2_name"{
  description = "Name of second public subnet"
}

variable "subnet_2_cidr"{
  description = "CIDR for second subnet public"
}

variable "ig_name"{
  description = "Name of internet gateway"
}

variable "rt_name"{
  description = "Name of route table"
}
variable "rt_cidr"{
  description = "CIDR for rt"
}

variable "zone_1" {
  description = "zones"
}

variable "zone_2"{
  description = "zones"
}

variable "alb_name"{
  description = "Name of application load balancer"
}

variable "sg_lb_name"{
  description = "security group for load balancer name"
}

variable "sg_lb_cidr"{
  description = "cidr for lb sg"
}

variable "sg_ws_name"{
  description = "name for sg for webservers"
}

variable "sg_ws_cidr"{
  description = "cidr for wb sg"
}

variable "lc_name"{
  description = "launch configuration name"
}

variable "lc_ami"{
  description = "ami of machine to be launched using lc"
}

variable "lc_type"{
  description = "type of the instance to be launched"
}

variable "key_name"{
  description = "ssh key name to be used"
}

variable "as_name"{
  description = "name of the autoscaling group"
}

variable "tg_name"{
  description = "name of the target group"
}
