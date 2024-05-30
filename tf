
module "dgarchive_basic_infra_warn_alarms" {
  source  = "app.terraform.io/avaloq/aoc-cloudwatch-metric-alarm/aws"
  version = "1.2.1"

  for_each = { for j, w in var.ec2_dgarchive_basic_alarms_and_warn_threshold :
    w.metric_name => w
  }

  enable_cloudwatch_static_alarm = length(local.dgarchive_instance_id) > 0 ? true : false

  alarm_name          = each.value.alarm_name
  alarm_description   = format("%s. %s", "Created via client-rbc-observability", each.value.description)
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold
  period              = each.value.period
  treat_missing_data  = each.value.treat_missing_data

  namespace   = each.value.namespace
  metric_name = each.value.metric_name
  statistic   = each.value.statistic

  dimensions = {
    InstanceId = "${local.dgarchive_instance_id}"
  }

  alarm_actions = [local.pagerduty_alerts_arn]
}



variable "ec2_dgarchive_basic_alarms_and_warn_threshold" {
  description = "CPU util, disk and memory alarm for dgarchive"
  type        = list(any)
  default = [
    {
      metric_name         = "LogicalDisk % Free Space"
      namespace           = "dgArchive"
      evaluation_periods  = 1
      threshold           = 20
      period              = 600
      treat_missing_data  = "notBreaching"
      description         = "Disk usage is over 80%"
      comparison_operator = "LessThanOrEqualToThreshold"
      statistic           = "Average"
      alarm_name          = "alrt-cw-ec2-windows-dgarchive-disk-utilization-warn"
    },
  ]
}



DgArchive Alarm Output
output "cw_dgarchive_alarm_arn" {
  value = [for dgarchive_alarm in module.dgarchive_basic_infra_alarms : dgarchive_alarm.cloudwatch_metric_alarm_arn]
output "cw_dgarchive_crit_alarm_arn" {
  value = [for dgarchive_alarm in module.dgarchive_basic_infra_crit_alarms : dgarchive_alarm.cloudwatch_metric_alarm_arn]
}

output "cw_dgarchive_alarm_id" {
  value = [for dgarchive_alarm in module.dgarchive_basic_infra_alarms : dgarchive_alarm.cloudwatch_metric_alarm_id]
output "cw_dgarchive_crit_alarm_id" {
  value = [for dgarchive_alarm in module.dgarchive_basic_infra_crit_alarms : dgarchive_alarm.cloudwatch_metric_alarm_id]
}

output "cw_dgarchive_warn_alarm_arn" {
  value = [for dgarchive_alarm in module.dgarchive_basic_infra_warn_alarms : dgarchive_alarm.cloudwatch_metric_alarm_arn]
}

output "cw_dgarchive_warn_alarm_id" {
  value = [for dgarchive_alarm in module.dgarchive_basic_infra_warn_alarms : dgarchive_alarm.cloudwatch_metric_alarm_id]
}
