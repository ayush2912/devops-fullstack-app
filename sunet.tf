resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    "Name"                       = "public-us-east-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/offsetmax-cluster" = "shared"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b"

  tags = {
    "Name"                       = "public-us-east-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/offsetmax-cluster" = "shared"
  }
}
