resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = local.tags

}
##########################################
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}
##########################################
resource "aws_s3_bucket_policy" "s3policy" {
  bucket = aws_s3_bucket.website.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::birthmodel1-uat-asset/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "${aws_cloudfront_distribution.cloudfront.arn}"
                }
            }
        }
    ]
}
POLICY
}
#############################################
#resource "aws_s3_bucket_acl" "website" {
#  bucket = aws_s3_bucket.website.id
#  acl    = "private"

resource "aws_s3_bucket_public_access_block" "s3block" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
####################################
resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "example"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}
###################################
locals {
  restrict_viewer_access = true
  s3_origin_id           = "myS3Origin"
}
#####################################
#resource "pub_id" "id" {
#byte_length = 4
#}

resource "aws_cloudfront_key_group" "cf_keygroup" {
  items = [aws_cloudfront_public_key.cf_key.id]
  name  = var.key_group_name
}
###########################################

resource "aws_cloudfront_distribution" "cloudfront" {
  comment = "uat-assets"
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
    origin_id                = local.s3_origin_id

  }


  enabled             = true
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"

    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    trusted_key_groups = [aws_cloudfront_key_group.cf_keygroup.id]


    forwarded_values {
      headers      = []
      query_string = false

      cookies {
        forward = "all"
      }
    }
  }
}
#####################################################
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.endpoint}"
}
##################################################
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
}

resource "aws_cloudfront_public_key" "cf_key" {
  name        = "cf-uat"
  encoded_key = tls_private_key.keypair.public_key_pem
}

# aliases             = [var.endpoint]

#restrictions {
#  geo_restriction {
#    restriction_type = "none"

# }
#}

# s3_origin_config {
#  origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#}

# trusted_key_groups {
#   items        = [aws_cloudfront_key_group.example-key-group_config[0].items[0]]
#   include_body = false

#  trusted_key_groups = []


# viewer_certificate {
#   acm_certificate_arn      = aws_acm_certificate.cert.arn
#   ssl_support_method       = "sni-only"
#   minimum_protocol_version = "TLSv1.2_2018"
#}

#tags = local.tags

#resource "aws_acm_certificate_validation" "certvalidation" {
#  provider                = aws.us-east-1
#  certificate_arn         = aws_acm_certificate.cert.arn
#  validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
#}

#resource "aws_acm_certificate" "cert" {
#provider                  = aws.us-east-1
# domain_name = var.domain_name
# subject_alternative_names = ["*.${var.domain_name}"]
#  validation_method = "DNS"
# tags              = local.tags
#}
#################################################




















    
