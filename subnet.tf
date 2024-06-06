resource "aws_default_subnet" "default_az1" {
  availability_zone = "ap-south-1a"

  tags = {
    "Name"                       = "public-ap-south-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/offsetmax-cluster" = "shared"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "ap-south-1b"

  tags = {
    "Name"                       = "public-ap-south-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/offsetmax-cluster" = "shared"
  }
}
