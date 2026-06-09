
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name = "$[var.project_name]-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 80

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_description = "EC2 CPU utilization is above 80%"

  tags = {
    Name = "${var.project_name}-cpu-alarm"
    Environment = var.environment
  }
}