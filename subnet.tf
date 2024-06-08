resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    "Name"                       = "private-us-east-1"
    
    "kubernetes.io/cluster/my-cluster" = "shared"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b"

  tags = {
    "Name"                       = "private-us-east-1"
   
    "kubernetes.io/cluster/my-cluster" = "shared"
  }
}
resource "aws_default_subnet" "default_az3" {
  availability_zone = "us-east-1b"

  tags = {
    "Name"                       = "public-us-east-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/my-cluster" = "shared"
  }
}
resource "aws_default_subnet" "default_az4" {
  availability_zone = "us-east-1b"

  tags = {
    "Name"                       = "public-us-east-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/my-cluster" = "shared"
  }
}
