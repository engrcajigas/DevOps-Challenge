resource "aws_autoscaling_group" "auto_scaling_group" {
  name             = "${var.tag_name_prefix}-auto-scaling-group"
  min_size         = 1
  desired_capacity = 1
  max_size         = 3
  force_delete     = true
  depends_on = [
    var.alb
  ]
  target_group_arns    = [var.alb_target_group.arn]
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.launch_config.name

  vpc_zone_identifier = [
    "${var.private_subnet1_id}",
    "${var.private_subnet2_id}"
  ]

  tag {
    key                 = "Name"
    value               = "${var.tag_name_prefix}-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "launch_config" {

  image_id      = data.aws_ami.latest_amzn2_ami.id
  instance_type = var.instance_type
  #key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile

  security_groups = [
    "${var.security_group_alb_id}"
  ]
  associate_public_ip_address = false
  user_data                   = file("${path.module}/user_data.sh")

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    encrypted   = true
    volume_size = 10
    volume_type = "gp2"
  }
}

resource "aws_autoscaling_policy" "asg_policy_up" {
  name                   = "${var.tag_name_prefix}-asg-policy-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_up" {
  alarm_name          = "cpu_alarm_up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.auto_scaling_group.name}"
  }

  alarm_description = "CPU Utilization Alarm > 80 for EC2 Instances"
  alarm_actions     = ["${aws_autoscaling_policy.asg_policy_up.arn}"]
}

resource "aws_autoscaling_policy" "asg_policy_down" {
  name                   = "${var.tag_name_prefix}-asg-policy-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_down" {
  alarm_name          = "cpu_alarm_down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.auto_scaling_group.name}"
  }

  alarm_description = "CPU Utilization Alarm < 60 for EC2 Instances"
  alarm_actions     = ["${aws_autoscaling_policy.asg_policy_down.arn}"]
}
