terraform {
  backend "s3" {
    bucket         = "eks-test-new"
    key            = "eks-test/terraform.tfstate"
    region         = "ap-south-1"
      
  }
}
