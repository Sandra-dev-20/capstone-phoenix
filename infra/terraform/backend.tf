terraform {
  backend "s3" {
    bucket       = "phoenix-terraform-state-sandie"
    key          = "capstone/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }
}
