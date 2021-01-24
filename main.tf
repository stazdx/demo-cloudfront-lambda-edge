## S3 Policy - OAI Cloudfront

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
      "arn:aws:s3:::cf-demo-lambda-edge-200/*"
    ]
  }
}

## S3 Bucket - Donde alojaremos nuestra web

resource "aws_s3_bucket" "cf-demo" {
  bucket        = "cf-demo-lambda-edge-200"
  acl           = "private"
  policy        = data.aws_iam_policy_document.s3_policy.json
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Name = "cf-demo"
  }
}

## Archivos a subir a nuestro bucket S3

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.cf-demo.id
  key    = "index.html"
  source = "src/index.html"

  content_type = "text/html"
}

resource "aws_s3_bucket_object" "css" {
  bucket = aws_s3_bucket.cf-demo.id
  key    = "styles.css"
  source = "src/styles.css"

  content_type = "text/css"
}

resource "aws_s3_bucket_object" "png" {
  bucket = aws_s3_bucket.cf-demo.id
  key    = "awsconf.png"
  source = "src/awsconf.png"
}

# resource "aws_s3_bucket_object" "object" {
#   for_each = fileset("src/", "*")
#   bucket   = aws_s3_bucket.cf-demo.id
#   key      = each.value
#   source   = "src/${each.value}"
#   etag     = filemd5("src/${each.value}")
# }

## OAI Cloudfront

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cf-demo"
}

## Distribución de Cloudfront

resource "aws_cloudfront_distribution" "cf_demo" {

  ## Definimos nuestro origen y asociamos el OAI 

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

  ## Objeto por defecto
  
  default_root_object = "index.html"


  ## Parametros para manejar la caché

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

    ## Asociacion de nuestro Lambda@Edge
    lambda_function_association {
      event_type = "viewer-response"
      lambda_arn = aws_lambda_function.lambda_edge.qualified_arn
    }
  }
 
  ## Manejo de errores

  custom_error_response {
    error_caching_min_ttl  = 10
    error_code             = 403
    response_code          = 200
    response_page_path     = "/index.html"
  }

  ## Restricción de acceso (geográfica)
  
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
