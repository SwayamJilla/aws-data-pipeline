provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "your-s3-bucket"
}

resource "aws_rds_instance" "db" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13.2"
  instance_class       = "db.t2.micro"
  name                 = "yourdbname"
  username             = "youruser"
  password             = "yourpassword"
  parameter_group_name = "default.postgres13"
}

resource "aws_ecr_repository" "repo" {
  name = "your-ecr-repo"
}

resource "aws_lambda_function" "lambda" {
  function_name = "your-lambda-function"
  role          = aws_iam_role.iam_for_lambda.arn
  image_uri     = "${aws_ecr_repository.repo.repository_url}:latest"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
