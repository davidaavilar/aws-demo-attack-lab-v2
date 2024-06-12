resource "aws_s3_bucket" "data" {
  bucket        = "${var.deployment_name}-${random_string.unique_id.result}"
  force_destroy = true
  tags = merge({
    Name = "${var.deployment_name}-${random_string.unique_id.result}"
  })
}

resource "aws_s3_bucket" "mgt" {
  bucket        = "${var.deployment_name}-${random_string.unique_id.result}"
  force_destroy = true
  tags = merge({
    Name = "${var.deployment_name}-${random_string.unique_id.result}"
  })
}


resource "aws_s3_bucket_server_side_encryption_configuration" "mgt" {
  bucket = aws_s3_bucket.mgt.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}



output "s3_bucket" {
  value = aws_s3_bucket.data.bucket
}
