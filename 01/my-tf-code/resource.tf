resource "aws_api_gateway_rest_api" "api_gateway" {
  description = "Example API Gateway"
  endpoint_configuration {
    types = [
      "REGIONAL"
    ]
  }
  name = var.api_gateway_name
}

resource "aws_api_gateway_method" "api_gateway_root_method" {
  authorization = "NONE"
  http_method = var.api_gateway_http_method
  // CF Property(Integration) = {
  //   IntegrationHttpMethod = "POST"
  //   Type = "AWS_PROXY"
  //   Uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda_function.arn}/invocations"
  // }
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway.arn
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.arn
  // CF Property(StageName) = var.api_gateway_stage_name
}

resource "aws_lambda_function" "lambda_function" {
  code_sha256 = {
    ZipFile = "def handler(event,context):
  return {
    'body': 'Hello there {0}'.format(event['requestContext']['identity']['sourceIp']),
    'headers': {
      'Content-Type': 'text/plain'
    },
    'statusCode': 200
  }
"
  }
  description = "Example Lambda function"
  function_name = var.lambda_function_name
  handler = "index.handler"
  memory_size = 128
  role = aws_iam_role.lambda_iam_role.arn
  runtime = "python3.8"
}

resource "aws_lambda_permission" "lambda_api_gateway_invoke" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api_gateway.arn}/${var.api_gateway_stage_name}/${var.api_gateway_http_method}/"
}

resource "aws_iam_role" "lambda_iam_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ]
            Effect = "Allow"
            Resource = [
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_function_name}:*"
            ]
          }
        ]
      }
      PolicyName = "lambda"
    }
  ]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 90
}

