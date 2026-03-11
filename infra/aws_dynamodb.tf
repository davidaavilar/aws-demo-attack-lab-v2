resource "aws_dynamodb_table" "customers_provisioned" {
  name         = "customers-provisioned"
  billing_mode = "PROVISIONED"
  hash_key     = "customer_id"

  read_capacity  = 10
  write_capacity = 10

  attribute {
    name = "customer_id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Environment = "demo"
    DataType    = "masked-sensitive"
  }
}

resource "aws_dynamodb_table" "payments_ondemand" {
  name         = "payments-ondemand"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "payment_id"

  attribute {
    name = "payment_id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Environment = "demo"
    DataType    = "tokenized-sensitive"
  }
}

resource "aws_dynamodb_table_item" "customer_1" {
  table_name = aws_dynamodb_table.customers_provisioned.name
  hash_key   = aws_dynamodb_table.customers_provisioned.hash_key

  item = jsonencode({
    customer_id = { S = "cust-001" }
    first_name  = { S = "David" }
    last_name   = { S = "Avila" }
    email       = { S = "david.avila@example.com" }
    phone       = { S = "+1-555-0101" }
    card_number = { S = "4012001037141112" }
    card_token  = { S = "tok_demo_abc123" }
    card_cvv    = { S = "467" }
  })
}

resource "aws_dynamodb_table_item" "customer_2" {
  table_name = aws_dynamodb_table.customers_provisioned.name
  hash_key   = aws_dynamodb_table.customers_provisioned.hash_key

  item = jsonencode({
    customer_id = { S = "cust-002" }
    first_name  = { S = "Maria" }
    last_name   = { S = "Gomez" }
    email       = { S = "maria.gomez@example.com" }
    phone       = { S = "+1-555-0102" }
    card_number = { S = "5123456789012346" }
    card_token  = { S = "tok_demo_xyz789" }
    card_cvv    = { S = "345" }
  })
}

resource "aws_dynamodb_table_item" "payment_1" {
  table_name = aws_dynamodb_table.payments_ondemand.name
  hash_key   = aws_dynamodb_table.payments_ondemand.hash_key

  item = jsonencode({
    payment_id  = { S = "pay-001" }
    customer_id = { S = "cust-001" }
    amount      = { N = "150.75" }
    currency    = { S = "USD" }
    card_brand  = { S = "VISA" }
    card_number = { S = "4012001037141112" }
    card_cvv    = { S = "467" }
    card_token  = { S = "tok_demo_abc123" }
    cardholder  = { S = "David Avila" }
    status      = { S = "AUTHORIZED" }
  })
}

resource "aws_dynamodb_table_item" "payment_2" {
  table_name = aws_dynamodb_table.payments_ondemand.name
  hash_key   = aws_dynamodb_table.payments_ondemand.hash_key

  item = jsonencode({
    payment_id  = { S = "pay-002" }
    customer_id = { S = "cust-002" }
    amount      = { N = "89.99" }
    currency    = { S = "USD" }
    card_brand  = { S = "MASTERCARD" }
    card_number = { S = "5123456789012346" }
    card_cvv    = { S = "345" }
    card_token  = { S = "tok_demo_xyz789" }
    cardholder  = { S = "Maria Gomez" }
    status      = { S = "CAPTURED" }
  })
}

resource "aws_dynamodb_table_item" "payment_3" {
  table_name = aws_dynamodb_table.payments_ondemand.name
  hash_key   = aws_dynamodb_table.payments_ondemand.hash_key

  item = jsonencode({
    payment_id  = { S = "pay-003" }
    customer_id = { S = "cust-002" }
    amount      = { N = "109.99" }
    currency    = { S = "USD" }
    card_brand  = { S = "MASTERCARD" }
    card_number = { S = "5123456789012346" }
    card_cvv    = { S = "345" }
    card_token  = { S = "tok_demo_xyz789" }
    cardholder  = { S = "Maria Gomez" }
    status      = { S = "CAPTURED" }
  })
}

output "customers_table_name" {
  value = aws_dynamodb_table.customers_provisioned.name
}

output "payments_table_name" {
  value = aws_dynamodb_table.payments_ondemand.name
}