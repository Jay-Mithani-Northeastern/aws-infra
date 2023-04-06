resource "aws_launch_template" "launch_template" {
  name          = "asg_launch_config"
  instance_type = var.instance_type
  image_id      = var.ami
  key_name      = var.key_name
  network_interfaces {
    security_groups             = [aws_security_group.instance.id]
    associate_public_ip_address = true
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
      echo DATABASE_URL=${var.db_dialect}://${var.db_username}:${var.db_password}@${aws_db_instance.postgresql_instance.endpoint}/${var.db_name} >> /etc/environment
      echo S3_BUCKET_NAME=${aws_s3_bucket.private.bucket} >> /etc/environment
      systemctl restart webapp.service
    EOF
  )
  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
    }
  }
}