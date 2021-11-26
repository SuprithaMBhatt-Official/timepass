region  = "us-east-1"
dev_prefix  = "dev"
vpc_name = "trail-vpc"
vpc_cidr = "10.0.0.0/16"
project_name = "Userstory3-dev"
subnet_1_name = "pub_sub_1"
subnet_1_cidr = "10.0.0.0/24"
subnet_2_name = "pub_sub_2"
subnet_2_cidr = "10.0.1.0/24"
zone_1 = "us-east-1a"
zone_2 = "us-east-1b"
ig_name = "trail-ig"
rt_name = "trail-rt"
rt_cidr = "0.0.0.0/0"
alb_name = "trail-alb"
sg_lb_name = "trail-sg-lb"
sg_lb_cidr = "0.0.0.0/0"
sg_ws_name = "trail-sg-ws"
sg_ws_cidr = "0.0.0.0/0"
lc_name = "trail-launchconfig"
lc_ami = "ami-04ad2567c9e3d7893"
lc_type = "t2.micro"
key_name = "NV-key1"
as_name = "trail-autoscaling"
tg_name = "trail-targetgroup"