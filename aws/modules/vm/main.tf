resource "aws_instance" "vm" {
  for_each      = var.instances
  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id     = var.subnet_lookup[each.value.subnet_key]
  vpc_security_group_ids = [for sg_key in each.value.security_group_keys : var.sg_lookup[sg_key]]
  tags          = try(each.value.tags, {})
}