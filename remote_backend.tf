terraform {
  backend "s3" {
    bucket         = "my-fbp"
    key            = "fbp/terraform.tfstate"
    region         = "us-east-1"
      
  }
}
