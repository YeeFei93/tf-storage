data "aws_vpc" "main" {
	filter {
		name   = "tag:Name"
		values = ["ce11-tf-vpc-*"]
	}
}

data "aws_subnet" "main" {
	filter {
		name   = "tag:Name"
		values = ["*-public-*"]
	}
	filter {
		name   = "availability-zone"
		values = ["us-east-1a"]
	}
	vpc_id = data.aws_vpc.main.id
}

resource "aws_instance" "web" {
	ami           = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI (us-east-1)
	instance_type = "t3.micro"
	subnet_id     = data.aws_subnet.main.id
	
	tags = {
		Name = "yeefei-ec2-tf"
	}
}

resource "aws_ebs_volume" "storage" {
	availability_zone = data.aws_subnet.main.availability_zone
	size              = 1
	type              = "gp3"
	iops              = 3000
	
	tags = {
		Name = "yeefei-ebs-tf"
	}
}

resource "aws_volume_attachment" "storage_attachment" {
	device_name = "/dev/sdb"
	volume_id   = aws_ebs_volume.storage.id
	instance_id = aws_instance.web.id
}
