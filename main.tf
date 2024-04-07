resource "aws_connect_instance" "main_contact_center" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  instance_alias           = var.connect_instance_name
  outbound_calls_enabled   = true
}

resource "aws_connect_phone_number" "main_contact_center" {
  target_arn   = aws_connect_instance.main_contact_center.arn
  country_code = "US"
  type         = "DID"

  tags = {
    "hello" = "contact ceneter phone number"
  }
}

resource "aws_connect_hours_of_operation" "main_contact_center" {
  instance_id = aws_connect_instance.main_contact_center.id
  name        = "Main Office Hours"
  description = "Monday office hours"
  time_zone   = "US/Central"

  config {
    day = "MONDAY"

    end_time {
      hours   = 23
      minutes = 8
    }

    start_time {
      hours   = 8
      minutes = 0
    }
  }

  config {
    day = "TUESDAY"

    end_time {
      hours   = 21
      minutes = 0
    }

    start_time {
      hours   = 9
      minutes = 0
    }
  }

  depends_on = [
    aws_connect_instance.main_contact_center
  ]
  tags = {
    "Name" = "Example Hours of Operation"
  }
}

resource "aws_connect_queue" "main_contact_center" {
  instance_id           = aws_connect_instance.main_contact_center.id
  name                  = "Sales Queue"
  description           = "This is a Sales Queue"
  hours_of_operation_id = aws_connect_hours_of_operation.main_contact_center.hours_of_operation_id

  depends_on = [
    aws_connect_hours_of_operation.main_contact_center
  ]

  tags = {
    "Name" = "Sales Queue for main contact center"
  }
}

resource "aws_connect_routing_profile" "routing_profile" {
  instance_id               = aws_connect_instance.main_contact_center.id
  name                      = var.common_name
  default_outbound_queue_id = aws_connect_queue.main_contact_center.queue_id
  description               = "${var.common_name} Routing Profile"
  media_concurrencies {
    channel     = "VOICE"
    concurrency = 1
  }
  queue_configs {
    channel  = "VOICE"
    delay    = 0
    priority = 1
    queue_id = aws_connect_queue.main_contact_center.queue_id
  }
  tags = {
    "Name" = var.common_name,
  }
}

resource "aws_connect_security_profile" "security_profile" {
  instance_id = aws_connect_instance.main_contact_center.id
  name        = var.common_name
  description = "${var.common_name} security profile"
  permissions = [
    "BasicAgentAccess",
    "OutboundCallAccess",
  ]
  tags = {
    "Name" = "${var.common_name}"
  }
}

resource "aws_connect_user" "user" {
  instance_id        = aws_connect_instance.main_contact_center.id
  name               = "rjin@test.com"
  password           = "Password123"
  routing_profile_id = aws_connect_routing_profile.routing_profile.routing_profile_id
  security_profile_ids = [
    aws_connect_security_profile.security_profile.security_profile_id
  ]
  identity_info {
    first_name = "John"
    last_name  = "doe"
  }
  phone_config {
    after_contact_work_time_limit = 0
    phone_type                    = "SOFT_PHONE"
  }
}

resource "aws_connect_contact_flow" "main_contact_center" {
  instance_id  = aws_connect_instance.main_contact_center.id
  name         = "Jilani Test"
  description  = "Jilani Test Contact Flow Description"
  type         = "CONTACT_FLOW"
  filename     = "Test.json"
  content_hash = filebase64sha256("Test.json")
  tags = {
    "Name"        = "Test Contact Flow",
    "Application" = "Terraform",
    "Method"      = "Create"
  }
}