variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "birthmodel1-uat-asset"
}
variable "key_group_name" {
  type        = string
  description = "Name of the CloudFront Key Group"
  default     = "uat-kg"
}


#variable "cloudfront_public_key_name"{
#  type        = string
#  description = "Name of the CloudFront Key Group"
#  default     = "cf-uat" # Set a default value if desired
#}




variable "endpoint" {
  description = "Endpoint url"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}