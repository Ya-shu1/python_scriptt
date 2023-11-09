# creating variable file

# creating vpc
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# creating subnets
# creating cidr block for 1st subnet
variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

# creating cidr block for 2nd subnet
variable "subnet1_cidr" {
  default = "10.0.2.0/24"
}
