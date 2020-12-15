
variable "region" {
  type        = string
  description = "Region of the lambda function in AWS Cloud"
}

variable "function_name" {
  default = "block_function"
}

variable "handler" {
  default = "app.handler"
}

variable "runtime" {
  default = "python3.7"
}
