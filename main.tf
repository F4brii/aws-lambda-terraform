module "vpc" {
  source            = "./iac/vpc"
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "security_group_main" {
  name        = "security-group-main"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "role_person_lambdas" {
  source    = "./iac/iam/roles"
  role_name = "iam-role-person"
}

data "archive_file" "zip_nodejs_code" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "${path.module}/node-code.zip"
}

module "lambda_get_person_list" {
  source             = "./iac/lambda"
  function_name      = "func-get-person-list"
  filename           = "${path.module}/node-code.zip"
  role_arn           = module.role_person_lambdas.role_arn
  handler            = "src/functions/person/handler.getPersonList"
  runtime            = "nodejs14.x"
  subnet_ids         = [module.vpc.subnet_id]
  security_group_ids = [aws_security_group.security_group_main.id]
}

module "lambda_create_person" {
  source             = "./iac/lambda"
  function_name      = "func-create-person"
  filename           = "${path.module}/node-code.zip"
  role_arn           = module.role_person_lambdas.role_arn
  handler            = "src/functions/person/handler.createPerson"
  runtime            = "nodejs14.x"
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

