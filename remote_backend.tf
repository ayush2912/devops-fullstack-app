terraform {
  backend "s3" {
    bucket         = "my-test-fbp"
    key            = "fbp/terraform.tfstate"
    region         = "us-east-1"
      
  }
}
