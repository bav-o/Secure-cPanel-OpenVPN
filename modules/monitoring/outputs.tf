output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = aws_sns_topic.alerts.arn
}

output "cpu_alarm_arns" {
  description = "Map of instance name to CPU alarm ARN"
  value       = { for k, v in aws_cloudwatch_metric_alarm.cpu : k => v.arn }
}

output "status_check_alarm_arns" {
  description = "Map of instance name to status check alarm ARN"
  value       = { for k, v in aws_cloudwatch_metric_alarm.status_check : k => v.arn }
}
