
output "cf_distribution_domain_name" {
    value = aws_cloudfront_distribution.cf_demo.domain_name
    #sensitive = true
}
