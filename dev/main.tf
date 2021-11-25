provider "aws" {
    region  = var.region
}

#vpc creation
resource "aws_vpc" "main" {
 cidr_block = var.vpc_cidr
 tags = {
          Project = var.project_name
          Name = "${var.dev_prefix}-${var.vpc_name}"
        }
}

# Create Public Subnet1
resource "aws_subnet" "pub_sub1" {
vpc_id                  = aws_vpc.main.id
cidr_block              = var.subnet_1_cidr
availability_zone       = var.zone_1
map_public_ip_on_launch = true
tags = {
         Project = var.project_name
         Name = "${var.dev_prefix}-${var.subnet_1_name}"
      }
}
# Create Public Subnet2
resource "aws_subnet" "pub_sub2" {
vpc_id                  = aws_vpc.main.id
cidr_block              = var.subnet_2_cidr
availability_zone       = var.zone_2
map_public_ip_on_launch = true
tags = {
         Project = var.project_name
         Name = "${var.dev_prefix}-${var.subnet_2_name}"
       }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.main.id
   tags = {
            Project = var.project_name
            Name = "${var.dev_prefix}-${var.ig_name}"
          }
}

# Create Public Route Table
resource "aws_route_table" "pub_sub1_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.rt_cidr
    gateway_id = aws_internet_gateway.igw.id
   }
    tags = {
    Project = var.project_name
    Name = "${var.dev_prefix}-${var.rt_name}"
 }
}
# Create route table association of public subnet1
resource "aws_route_table_association" "internet_for_pub_sub1" {
  route_table_id = aws_route_table.pub_sub1_rt.id
  subnet_id      = aws_subnet.pub_sub1.id
}
# Create route table association of public subnet2
resource "aws_route_table_association" "internet_for_pub_sub2" {
  route_table_id = aws_route_table.pub_sub1_rt.id
  subnet_id      = aws_subnet.pub_sub2.id
}


# Create security group for load balancer
resource "aws_security_group" "elb_sg" {
  name        = "${var.dev_prefix}-${var.sg_lb_name}"
  description = "sg for application load balancer"
  vpc_id      = aws_vpc.main.id
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = [var.sg_lb_cidr]
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

 tags = {
    Name = "${var.dev_prefix}-${var.sg_lb_name}"
    Project = var.project_name
  }
}
# Create security group for webserver
resource "aws_security_group" "webserver_sg" {
  name        = "${var.dev_prefix}-${var.sg_ws_name}"
  description = "security group for webserver"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = [var.sg_ws_cidr]
   }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH"
    cidr_blocks = [var.sg_ws_cidr]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.dev_prefix}-${var.sg_ws_name}"
    Project = var.project_name
  }
}

#Create Launch config
resource "aws_launch_configuration" "webserver-launch-config" {
  name_prefix   = "${var.dev_prefix}-${var.lc_name}"
  image_id      =  var.lc_ami
  instance_type = var.lc_type
  key_name =  var.key_name
  security_groups = ["${aws_security_group.webserver_sg.id}"]

  root_block_device {
            volume_type = "gp2"
            volume_size = 10
            encrypted   = true
        }
  ebs_block_device {
            device_name = "/dev/sdf"
            volume_type = "gp2"
            volume_size = 5
            encrypted   = true
        }
lifecycle {
        create_before_destroy = true
     }
  user_data = filebase64("${path.module}/init_webserver.sh")
}





# Create Auto Scaling Group
resource "aws_autoscaling_group" "Demo-ASG-tf" {
  name       = "${var.dev_prefix}-${var.as_name}"
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  force_delete       = true
  depends_on         = [aws_lb.ALB-tf]
  target_group_arns  =  ["${aws_lb_target_group.TG-tf.arn}"]
  health_check_type  = "EC2"
  launch_configuration = aws_launch_configuration.webserver-launch-config.name
  vpc_zone_identifier = ["${aws_subnet.pub_sub1.id}","${aws_subnet.pub_sub2.id}"]

 tag {
       key                 = "Name"
       value               = "${var.dev_prefix}-${var.as_name}"
       propagate_at_launch = true
    }
}


# Create Target group
resource "aws_lb_target_group" "TG-tf" {
  name     = "${var.dev_prefix}-${var.tg_name}"
  depends_on = [aws_vpc.main]
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    interval            = 70
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

# Create ALB
resource "aws_lb" "ALB-tf" {
   name              = "${var.dev_prefix}-${var.alb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups  = [aws_security_group.elb_sg.id]
  subnets          = [aws_subnet.pub_sub1.id,aws_subnet.pub_sub2.id]
  tags = {
        name  = "${var.dev_prefix}-${var.alb_name}"
        Project = var.project_name
       }
}


# Create ALB Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ALB-tf.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG-tf.arn
  }
}