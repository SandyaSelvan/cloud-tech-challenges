variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}
variable "monitoring" {
  type = bool
}
variable "associate_public_ip_address" {
  type = bool
}
variable "tags" {
  type = string
}
variable "associate_public_ip_address_app" {
  type = bool
}
variable "private_ip" {
  type = string
}
variable "tags_app" {
  type = string
}
variable "igw_name" {
  type = string
}
variable "destination_cidr_block" {
  type = string
}

variable "priv1_rt" {
  type = string
}

variable "priv_cidr_block" {
  description = "CIDR block for public subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "priv_availability_zones" {
  description = "Availability zones for public subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1a", "us-east-1b"]
}

variable "priv_tag_subnet" {
  type        = string
  default     = "private-subnet"
}

variable "pub_cidr_block" {
  description = "CIDR block for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = true
}

variable "pub_availability_zones" {
  description = "Availability zones for public subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "pub_tag_subnet" {
  type        = string
  default     = "public-subnet"
}

variable "pub_rt" {
  type = string
}
variable "cidr_block" {
  type = string
}
variable "enable_dns_support" {
  type = string
}
variable "enable_dns_hostnames" {
  type = string
}
variable "vpc_name" {
  type = string
}
