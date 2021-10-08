provider "aws" {
  version = "~> 2.57.0"
  region  = "us-west-2"
}

resource "aws_instance" "terraform_demo" {
  ami = "ami-0cf6f5c8a62fa5da6"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_profile.name}"

}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
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
  role       = "${aws_iam_role.ec2_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}