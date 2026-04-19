variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g., 'dev', 'staging', 'prod')"
}

variable "region_short" {
  type        = string
  description = "Short region code used in naming (e.g., 'use1', 'usw2')"
}

variable "functions" {
  type = map(object({
    # Core
    function_name = optional(string)
    description   = optional(string)
    handler       = optional(string, "index.handler")
    runtime       = optional(string, "nodejs20.x")
    architectures = optional(list(string), ["arm64"])
    memory_size   = optional(number, 128)
    timeout       = optional(number, 3)
    publish       = optional(bool, false)
    tags          = optional(map(string))

    # Code Source
    source_path             = optional(any)
    s3_existing_package     = optional(any)
    store_on_s3             = optional(bool, false)
    s3_bucket               = optional(string)
    s3_prefix               = optional(string)
    create_package          = optional(bool, true)
    local_existing_package  = optional(string)
    ignore_source_code_hash = optional(bool, false)

    # Security - HARDENED defaults
    tracing_mode                   = optional(string, "Active")
    attach_tracing_policy          = optional(bool, true)
    kms_key_arn                    = optional(string)
    code_signing_config_arn        = optional(string)
    reserved_concurrent_executions = optional(number, -1)

    # CloudWatch Logs
    attach_cloudwatch_logs_policy     = optional(bool, true)
    cloudwatch_logs_retention_in_days = optional(number, 30)
    cloudwatch_logs_kms_key_id        = optional(string)

    # VPC
    vpc_subnet_ids         = optional(list(string))
    vpc_security_group_ids = optional(list(string))
    attach_network_policy  = optional(bool)

    # IAM
    lambda_role              = optional(string)
    role_name                = optional(string)
    role_permissions_boundary = optional(string)
    attach_policy_json       = optional(bool, false)
    policy_json              = optional(string)
    attach_policy_jsons      = optional(bool, false)
    policy_jsons             = optional(list(string), [])
    attach_policy            = optional(bool, false)
    policy                   = optional(string)
    attach_policies          = optional(bool, false)
    policies                 = optional(list(string), [])
    number_of_policies       = optional(number, 0)
    attach_policy_statements = optional(bool, false)
    policy_statements        = optional(any, {})

    # Dead Letter
    dead_letter_target_arn    = optional(string)
    attach_dead_letter_policy = optional(bool, false)

    # Environment
    environment_variables = optional(map(string), {})

    # Layers
    layers = optional(list(string))

    # Event Source Mapping
    event_source_mapping = optional(any, {})

    # Triggers
    allowed_triggers = optional(map(any), {})

    # Function URL
    create_lambda_function_url = optional(bool, false)
    authorization_type         = optional(string, "AWS_IAM")
    cors                       = optional(any, {})
  }))
  description = "Map of Lambda function configurations to create"
  default     = {}
}
