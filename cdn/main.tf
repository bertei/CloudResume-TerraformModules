resource "aws_cloudfront_origin_access_control" "main" {
  name  = "cloudfront-control-settings"

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name              = var.domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = "bernatei-website-cdn"
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["bernatei.com"]

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

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_arn
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