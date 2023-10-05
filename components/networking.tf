module "api_vpc" {
  source                     = "../modules/networking"
  vpc_name                   = "falafel_vpc"
  vpc_cidr_block             = "10.1.0.0/24"
  private_subnet_cidr_blocks = local.private_subnet_cidr_blocks
  public_subnet_cidr_blocks  = local.public_subnet_cidr_blocks
}