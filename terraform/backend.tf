terraform {
  backend "s3" {
    bucket       = "bedrock-tfstate-alt-soe-tin-025-0256"
    key          = "state/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
