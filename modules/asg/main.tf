# Launch Template — blueprint for every EC2 instance ASG creates
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = "ami-0c02fb55956c7d316"   # Amazon Linux 2 in us-east-1
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false    # private subnet — no public IP
    security_groups             = [var.ec2_sg_id]
  }

  # User data — runs on every EC2 when it first boots
  # This installs a simple web server so we can test the ALB
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-ec2"
      Environment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "main" {
  name = "${var.project_name}-asg"
  min_size = 2
  max_size = 5
  desired_capacity = 2
  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [var.target_group_arn]

  health_check_type = "ELB"
  health_check_grace_period = 300

  launch_template {
    id = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key = "Name"
    value = "${var.project_name}-asg"
    propagate_at_launch = true
  }

}