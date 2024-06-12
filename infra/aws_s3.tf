resource "aws_s3_bucket" "data" {
  bucket        = "${var.deployment_name}-${random_string.unique_id.result}"
  force_destroy = true
  tags = merge({
    Name = "${var.deployment_name}-${random_string.unique_id.result}"
  })
}

resource "aws_s3_bucket" "mgt" {
  bucket        = "${var.deployment_name}-${random_string.unique_id.result}-mgt"
  force_destroy = true
  tags = merge({
    Name = "${var.deployment_name}-${random_string.unique_id.result}-mgt"
  })
}


resource "aws_s3_bucket_versioning" "mgt" {
  bucket = aws_s3_bucket.mgt.id

  versioning_configuration {
    status = "Enabled"
  }
}




output "s3_bucket" {
  value = aws_s3_bucket.data.bucket
}
