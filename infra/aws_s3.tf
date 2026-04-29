resource "aws_s3_bucket" "data" {
  bucket        = "${var.deployment_name}-${random_string.unique_id.result}"
  force_destroy = true
  tags = merge({
    Name = "${var.deployment_name}-${random_string.unique_id.result}"
  })
}

resource "aws_s3_object" "sensitive_customer_data_json" {
  bucket       = aws_s3_bucket.data.id
  key          = "test-data/customers/customer-001.json"
  content_type = "application/json"

  content = jsonencode({
    customer_id = "cust-001"
    first_name  = "David"
    last_name   = "Alvarez"
    email       = "david.alvarez@example.com"
    phone       = "+1-555-0101"
    card_number = "4012001037141112"
    card_token  = "tok_demo_abc123"
    card_cvv    = "467"
  })
}

resource "aws_s3_object" "sensitive_customer_data_csv" {
  bucket       = aws_s3_bucket.data.id
  key          = "test-data/customers/customers.csv"
  content_type = "text/csv"

  content = <<EOF
customer_id,first_name,last_name,email,phone,card_number,card_token,card_cvv
cust-001,David,Alvarez,david.alvarez@example.com,+1-555-0101,4012001037141112,tok_demo_abc123,467
cust-002,Ana,Gomez,ana.gomez@example.com,+1-555-0102,5555555555554444,tok_demo_def456,123
EOF
}

resource "aws_s3_object" "sensitive_customer_data_txt" {
  bucket       = aws_s3_bucket.data.id
  key          = "test-data/raw/customer-notes.txt"
  content_type = "text/plain"

  content = <<EOF
Customer: David Alvarez
Email: david.alvarez@example.com
Phone: +1-555-0101
Credit Card: 4012001037141112
CVV: 467
Token: tok_demo_abc123
EOF
}
#
output "s3_bucket" {
  value = aws_s3_bucket.data.bucket
}

