resource "aws_cloudwatch_log_metric_filter" "retail_app_errors" {
  name           = "RetailAppErrorCount"
  pattern        = "{ $.kubernetes.namespace_name = \"retail-app\" && $.log = \"*ERROR*\" }"
  log_group_name = "/aws/containerinsights/project-bedrock-cluster/application"

  metric_transformation {
    name      = "RetailAppErrors"
    namespace = "ContainerInsights/Applications"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "retail_app_high_errors" {
  alarm_name          = "EKS-RetailApp-High-Error-Rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.retail_app_errors.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.retail_app_errors.metric_transformation[0].namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"
}
