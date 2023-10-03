#CloudFront distribution to serve content using s3 as 'origin' to host the static website.
#It delivers your content from edge locations providing the lowest latency.

#OAC secures s3 origins by only allowing access to the CDN distribution.
#With OAC there is no need to set the bucket public. Only OAC will have access to it.
resource "aws_cloudfront_origin_access_control" "main" {
  name  = "cloudfront-control-settings"

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name              = var.domain_name #Bucket domain name as the origin
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = "bernatei-website-cdn"
  }

  enabled             = true #Whether the distribution is enabled to accept end user requests for content.
  default_root_object = "index.html"

  aliases = ["bernatei.com", "resume.bernatei.com"] #Alternate domain names

  dynamic custom_error_response {
    for_each = length(var.custom_error_response) > 0 ? var.custom_error_response : []

    content {
      error_code            = try(custom_error_response.value.error_code, null)
      error_caching_min_ttl = try(custom_error_response.value.error_caching_min_ttl, 10)
      response_code         = try(custom_error_response.value.response_code, null)
      response_page_path    = try(custom_error_response.value.response_page_path, null)
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "bernatei-website-cdn"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https" #Redirects http requests to https
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  #Method that you want to use to restrict distribution of your content by country
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  #SSL Configuration for this distribution
  viewer_certificate {
    acm_certificate_arn = var.acm_arn #ARN of the ACM certificate to use
    ssl_support_method  = "sni-only"
    #cloudfront_default_certificate = true
  }

  depends_on = [
    aws_cloudfront_origin_access_control.main
  ]
}

#Bucket policy for OAC - CDN
resource "aws_s3_bucket_policy" "main" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.allow_bucket_read.json

  depends_on = [ aws_cloudfront_distribution.main ]
}

#Allows only CloudFront to get every object (index.html) from the bucket (origin).
data "aws_iam_policy_document" "allow_bucket_read" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly-1"
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    condition {
      test      = "StringLike"
      variable  = "AWS:SourceArn"
      values    = [
        "${aws_cloudfront_distribution.main.arn}"
      ]
    }

    
    resources = [
      "${var.bucket_arn}/*"
    ]
  }
}