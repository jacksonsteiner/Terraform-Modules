locals {
  suffix = join("-", compact([var.project_name, var.environment, var.region_short]))

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  for_each = var.functions

  function_name = coalesce(try(each.value.function_name, null), "${local.suffix}-${each.key}")
  description   = try(each.value.description, null)
  handler       = coalesce(try(each.value.handler, null), "index.handler")
  runtime       = coalesce(try(each.value.runtime, null), "nodejs20.x")
  architectures = try(each.value.architectures, ["arm64"])
  memory_size   = coalesce(try(each.value.memory_size, null), 128)
  timeout       = coalesce(try(each.value.timeout, null), 3)
  publish       = coalesce(try(each.value.publish, null), false)

  # Code Source
  source_path             = try(each.value.source_path, null)
  s3_existing_package     = try(each.value.s3_existing_package, null)
  store_on_s3             = coalesce(try(each.value.store_on_s3, null), false)
  s3_bucket               = try(each.value.s3_bucket, null)
  s3_prefix               = try(each.value.s3_prefix, null)
  create_package          = coalesce(try(each.value.create_package, null), true)
  local_existing_package  = try(each.value.local_existing_package, null)
  ignore_source_code_hash = coalesce(try(each.value.ignore_source_code_hash, null), false)

  # Security - X-Ray Tracing (HARDENED: Active by default)
  tracing_mode          = coalesce(try(each.value.tracing_mode, null), "Active")
  attach_tracing_policy = coalesce(try(each.value.attach_tracing_policy, null), true)

  # Security - Encryption
  kms_key_arn             = try(each.value.kms_key_arn, null)
  code_signing_config_arn = try(each.value.code_signing_config_arn, null)

  # Concurrency
  reserved_concurrent_executions = try(each.value.reserved_concurrent_executions, -1)

  # CloudWatch Logs
  attach_cloudwatch_logs_policy     = coalesce(try(each.value.attach_cloudwatch_logs_policy, null), true)
  cloudwatch_logs_retention_in_days = coalesce(try(each.value.cloudwatch_logs_retention_in_days, null), 30)
  cloudwatch_logs_kms_key_id        = try(each.value.cloudwatch_logs_kms_key_id, null)

  # VPC Configuration
  vpc_subnet_ids         = try(each.value.vpc_subnet_ids, null)
  vpc_security_group_ids = try(each.value.vpc_security_group_ids, null)
  attach_network_policy  = try(each.value.vpc_subnet_ids, null) != null ? true : coalesce(try(each.value.attach_network_policy, null), false)

  # IAM Role
  lambda_role              = try(each.value.lambda_role, "")
  role_name                = try(each.value.role_name, null)
  role_permissions_boundary = try(each.value.role_permissions_boundary, null)
  attach_policy_json       = coalesce(try(each.value.attach_policy_json, null), false)
  policy_json              = try(each.value.policy_json, null)
  attach_policy_jsons      = coalesce(try(each.value.attach_policy_jsons, null), false)
  policy_jsons             = try(each.value.policy_jsons, [])
  attach_policy            = coalesce(try(each.value.attach_policy, null), false)
  policy                   = try(each.value.policy, null)
  attach_policies          = coalesce(try(each.value.attach_policies, null), false)
  policies                 = try(each.value.policies, [])
  number_of_policies       = try(each.value.number_of_policies, 0)
  attach_policy_statements = coalesce(try(each.value.attach_policy_statements, null), false)
  policy_statements        = try(each.value.policy_statements, {})

  # Dead Letter Queue
  dead_letter_target_arn    = try(each.value.dead_letter_target_arn, null)
  attach_dead_letter_policy = try(each.value.dead_letter_target_arn, null) != null ? true : coalesce(try(each.value.attach_dead_letter_policy, null), false)

  # Environment Variables
  environment_variables = try(each.value.environment_variables, {})

  # Layers
  layers = try(each.value.layers, null)

  # Event Source Mapping
  event_source_mapping = try(each.value.event_source_mapping, {})

  # Triggers
  allowed_triggers = try(each.value.allowed_triggers, {})

  # Function URL - HARDENED: AWS_IAM auth by default
  create_lambda_function_url = coalesce(try(each.value.create_lambda_function_url, null), false)
  authorization_type         = coalesce(try(each.value.authorization_type, null), "AWS_IAM")
  cors                       = try(each.value.cors, {})

  tags = merge(local.tags, try(each.value.tags, {}))
}
