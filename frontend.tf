provider "aws" {
  region  = "us-west-2"
}

/*
resource "aws_instance" "terraform_demo" {
  ami = "ami-0cf6f5c8a62fa5da6"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_profile.name}"

}
*/

resource "aws_iam_instance_profile" "frontend_role_profile" {
  name  = "frontend_role_profile"
  role = aws_iam_role.frontend_role.name
}

resource "aws_iam_role" "frontend_role" {
  name = "frontend_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.frontend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  #vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_launch_template" "frontend" {
  name_prefix   = "frontend_west"
  image_id      = "ami-0cf6f5c8a62fa5da6"
  instance_type = "t2.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.frontend_role_profile.name
  }
  #vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  key_name = "my"
}

resource "aws_autoscaling_group" "bar" {
  name               = "frontend_west"
  availability_zones = ["us-west-2a", "us-west-2b"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }
}