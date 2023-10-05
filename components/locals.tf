locals {
  public_subnet_cidr_blocks  = ["10.1.0.192/28", "10.1.0.208/28", "10.1.0.224/28"]
  private_subnet_cidr_blocks = ["10.1.0.0/26", "10.1.0.64/26", "10.1.0.128/26"]
}