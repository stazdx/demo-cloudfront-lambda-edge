data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      type = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
    resources = [
      "arn:aws:s3:::cf-demo-lambda-edge/*"
    ]
  }
}

resource "aws_s3_bucket" "cf-demo" {
  bucket        = "cf-demo-lambda-edge"
  acl           = "private"
  policy        = data.aws_iam_policy_document.s3_policy.json
  force_destroy = true
  tags = {
    Name = "cf-demo"
  }
}

resource "aws_s3_bucket_object" "object" {
  for_each = fileset("src/", "*")
  bucket   = aws_s3_bucket.cf-demo.id
  key      = each.value
  source   = "src/${each.value}"
  etag     = filemd5("src/${each.value}")
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cf-demo"
}

resource "aws_cloudfront_distribution" "cf_demo" {
  origin {
    domain_name = aws_s3_bucket.cf-demo.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = ""
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    lambda_function_association {
      event_type = "viewer-response"
      lambda_arn = aws_lambda_function.lambda_edge.qualified_arn
    }
  }

  custom_error_response {
    error_caching_min_ttl  = 10
    error_code             = 403
    response_code          = 200
    response_page_path     = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    demo = "cf-demo"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
