module "unlock" {
  source        = "../"
  lock_name     = var.lock_name
  scope         = var.resource_group_id
  force_reapply = var.force_reapply
}
