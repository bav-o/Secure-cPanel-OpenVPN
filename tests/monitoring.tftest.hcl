mock_provider "aws" {}

variables {
  instance_ids = {
    openvpn = "i-mock111"
    cpanel  = "i-mock222"
  }
  alert_emails  = ["test@example.com"]
  cpu_threshold = 80
  project_name  = "vcode"
  environment   = "test"
}

run "monitoring_creates_sns_topic" {
  command = plan

  module {
    source = "./modules/monitoring"
  }

  assert {
    condition     = aws_sns_topic.alerts.name == "vcode-test-alerts"
    error_message = "SNS topic should have correct name"
  }
}

run "monitoring_creates_email_subscriptions" {
  command = plan

  module {
    source = "./modules/monitoring"
  }

  assert {
    condition     = length(aws_sns_topic_subscription.email) == 1
    error_message = "Should create one email subscription"
  }
}

run "monitoring_cpu_alarms_per_instance" {
  command = plan

  module {
    source = "./modules/monitoring"
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.cpu) == 2
    error_message = "Should create CPU alarm for each instance"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.cpu["openvpn"].threshold == 80
    error_message = "CPU threshold should be 80%"
  }
}

run "monitoring_status_check_alarms" {
  command = plan

  module {
    source = "./modules/monitoring"
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.status_check) == 2
    error_message = "Should create status check alarm for each instance"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.status_check["cpanel"].threshold == 0
    error_message = "Status check threshold should be 0"
  }
}
