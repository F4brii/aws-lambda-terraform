module "vpc" {
  source            = "./iac/vpc"
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = module.vpc.vpc_id 
}


resource "aws_route_table" "route_table" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = module.vpc.subnet_id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "security_group_main" {
  name        = "security-group-main"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id
}

module "role_person_lambdas" {
  source    = "./iac/iam/roles"
  role_name = "iam-role-person"
}

resource "aws_dynamodb_table" "table_person" {
  name           = "ddb-person"
  billing_mode   = "PROVISIONED"
  hash_key       = "id"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "id"
    type = "N"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.dynamodb"
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  vpc_endpoint_id = aws_vpc_endpoint.vpc_endpoint.id
  route_table_id  = aws_route_table.route_table.id
}

data "archive_file" "zip_nodejs_code" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "${path.module}/node-code.zip"
}

module "lambda_get_person_list" {
  source        = "./iac/lambda"
  function_name = "func-get-person-list"
  filename      = "${path.module}/node-code.zip"
  role_arn      = module.role_person_lambdas.role_arn
  handler       = "src/functions/person/handler.getPersonList"
  runtime       = "nodejs16.x"
  lambda_env = {
    PERSON_TABLE = aws_dynamodb_table.table_person.name
  }
  subnet_ids         = [module.vpc.subnet_id]
  security_group_ids = [aws_security_group.security_group_main.id]
}

module "lambda_create_person" {
  source        = "./iac/lambda"
  function_name = "func-create-person"
  filename      = "${path.module}/node-code.zip"
  role_arn      = module.role_person_lambdas.role_arn
  handler       = "src/functions/person/handler.createPerson"
  runtime       = "nodejs16.x"
  lambda_env = {
    PERSON_TABLE = aws_dynamodb_table.table_person.name
  }
  subnet_ids         = [module.vpc.subnet_id]
  security_group_ids = [aws_security_group.security_group_main.id]
}

module "api_gateway_main" {
  source           = "./iac/api_gateway/api"
  api_gateway_name = "api-gw-main"
}

module "api_gateway_person_resource" {
  source                       = "./iac/api_gateway/resource"
  api_gateway_id               = module.api_gateway_main.api_gateway_id
  api_gateway_root_resource_id = module.api_gateway_main.api_gateway_root_resource_id
  path_part                    = "person"
}

module "person_http_get" {
  source                       = "./iac/api_gateway/method"
  aws_api_gateway_resource_id  = module.api_gateway_person_resource.aws_api_gateway_resource_id
  api_gateway_id               = module.api_gateway_main.api_gateway_id
  api_gateway_root_resource_id = module.api_gateway_main.api_gateway_root_resource_id
  api_gateway_execution_arn    = module.api_gateway_main.api_gateway_execution_arn
  http_method                  = "GET"
  authorization                = "NONE"
  lambda_invoke_arn            = module.lambda_get_person_list.lambda_invoke_arn
  env                          = var.env
  lambda_name                  = module.lambda_get_person_list.lambda_function_name

}

module "create_person_http_post" {
  source                       = "./iac/api_gateway/method"
  aws_api_gateway_resource_id  = module.api_gateway_person_resource.aws_api_gateway_resource_id
  api_gateway_id               = module.api_gateway_main.api_gateway_id
  api_gateway_root_resource_id = module.api_gateway_main.api_gateway_root_resource_id
  api_gateway_execution_arn    = module.api_gateway_main.api_gateway_execution_arn
  http_method                  = "POST"
  authorization                = "NONE"
  lambda_invoke_arn            = module.lambda_create_person.lambda_invoke_arn
  env                          = var.env
  lambda_name                  = module.lambda_create_person.lambda_function_name

}

module "dyanmodb_policy_attachment" {
  source             = "./iac/iam/policy"
  policy_name        = "dynamodb-policy"
  policy_description = "Dynamodb policy"
  policy_actions = [
    "dynamodb:PutItem",
    "dynamodb:Scan",
    "dynamodb:UpdateItem"
  ]
  resource_arn = aws_dynamodb_table.table_person.arn
  role_arn     = [module.role_person_lambdas.role_name]
}


