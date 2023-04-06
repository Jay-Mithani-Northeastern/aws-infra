resource "aws_autoscaling_group" "auto_scaling" {
  name                = "webApp_ASG"
  vpc_zone_identifier = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id, aws_subnet.public_subnet[2].id]
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  default_cooldown    = 60
  tag {
    key                 = "application"
    value               = "webapp"
    propagate_at_launch = true
  }
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  target_group_arns = [
    aws_lb_target_group.loadbalancer_targetgroup.arn
  ]

}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.auto_scaling.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 5.0
  }
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.auto_scaling.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 3.0
  }
}