resource "aws_s3_bucket" "data" {
  bucket        = "${var.deployment_name}-${random_string.unique_id.result}"
  force_destroy = true
  tags = merge({
    Name = "${var.deployment_name}-${random_string.unique_id.result}"
  })
}







output "s3_bucket" {
  value = aws_s3_bucket.data.bucket
}