variable "project_name" {

    type = string
    
}

variable "environment" {

    type = string
}

variable "vpc_cidr" {

    type = string
}

variable "enable_dns_hostnames" {

    type = bool
    default = true

}

variable "common_tags" {

    type = map 
    default = {}
}

variable "public_subnet_cidrs" {

    type = list

    validation {
       condition     = length(var.public_subnet_cidrs) == 2
       error_message = "please enter only two valid public subnet cidr_blocks"
  }
}

variable "private_subnet_cidrs" {

    type = list
    
    validation {
       condition     = length(var.private_subnet_cidrs) == 2
       error_message = "please enter only two valid private subnet cidr_blocks"
  }
}


variable "database_subnet_cidrs" {

    type = list
    
    validation {
       condition     = length(var.database_subnet_cidrs) == 2
       error_message = "please enter only two valid database subnet cidr_blocks"
  }
}

