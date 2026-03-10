locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# --- SNS Topic ---

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.alert_emails)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

# --- CPU Utilization Alarms ---

resource "aws_cloudwatch_metric_alarm" "cpu" {
  for_each = var.instance_ids

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "CPU utilization >${var.cpu_threshold}% on ${each.key}"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = each.value
  }

  tags = local.common_tags
}

# --- Status Check Alarms ---

resource "aws_cloudwatch_metric_alarm" "status_check" {
  for_each = var.instance_ids

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Status check failed on ${each.key}"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = each.value
  }

  tags = local.common_tags
}

# --- Disk Utilization Alarms (requires CloudWatch Agent) ---

resource "aws_cloudwatch_metric_alarm" "disk" {
  for_each = var.disk_monitor_instance_ids

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-disk-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = var.disk_threshold
  alarm_description   = "Disk usage >${var.disk_threshold}% on ${each.key}"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = each.value
    path       = "/"
    fstype     = "xfs"
  }

  tags = local.common_tags
}

# --- Memory Utilization Alarms (requires CloudWatch Agent) ---

resource "aws_cloudwatch_metric_alarm" "memory" {
  for_each = var.disk_monitor_instance_ids

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "Memory usage >${var.memory_threshold}% on ${each.key}"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = each.value
  }

  tags = local.common_tags
}
