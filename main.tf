module "aws_vpc" {
    source                  = "./modules/aws-vpc"
    for_each                = var.vpc_config
    vpc_cidr                = each.value.vpc_cidr
    instance_tenancy        = each.value.instance_tenancy
    tags                    = each.value.tags
}

module "subnet" {
    source                  = "./modules/aws-subnet"
    for_each                = var.subnet_config
    vpc_id                  = module.aws_vpc[each.value.vpc_name].vpc_id
    cidr_block              = each.value.cidr_block
    map_public_ip_on_launch = each.value.map_public_ip_on_launch
    availability_zone       = each.value.availability_zone
    tags                    = each.value.tags
}

module "igw" {
    source                  = "./modules/aws-igw"
    for_each                = var.igw_config
    vpc_id                  = module.aws_vpc[each.value.vpc_name].vpc_id
    tags                    = each.value.tags
}

module "route_table" {
    source                  = "./modules/aws-route-table"
    for_each                = var.route_table_config
    vpc_id                  = module.aws_vpc[each.value.vpc_name].vpc_id
    cidr_block              = each.value.cidr_block
    gateway_id              = module.igw[each.value.igw_name].igw_id
    tags                    = each.value.tags
}

module "route_table_association" {
    source                  = "./modules/aws-route-table-association"
    for_each                = var.route_table_association_config
    subnet_id               = module.subnet[each.value.subnet_name].subnet_id
    route_table_id          = module.route_table[each.value.table_name].route_table_id
}

module "security_group" {
    source                  = "./modules/aws-security-group"
    for_each                = var.security_group_config
    security-group-name     = each.value.security_group_name
    vpc-id                  = module.aws_vpc[each.value.vpc_name].vpc_id
}

module "lb_target_group" {
    source                  = "./modules/aws-lb-target-group"
    for_each                = var.lb_target_group_config
    alb-name                = each.value.alb-name
    vpc-id                  = module.aws_vpc[each.value.vpc_name].vpc_id
    port                    = each.value.port
    protocol                = each.value.protocol
    tags                    = each.value.tags
}