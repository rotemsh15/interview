## Variables ##

variable "s3_bucket_name" {
    type = string
    default = "nice-devops-interview-rotem"
}

variable "lambda_function_name" {
    type = string
    default = "lambda-nice-devops-interview-rotem"
}

variable "filename" {
    type = string
    default = "parse"
}