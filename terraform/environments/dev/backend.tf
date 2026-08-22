terraform {
  backend "s3" {
    bucket       = "enterprise-idp-tfstate-6c6ea2a7"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
