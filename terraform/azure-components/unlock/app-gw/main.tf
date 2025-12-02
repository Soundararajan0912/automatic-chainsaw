module "unlock" {
  source        = "../"
  lock_name     = var.lock_name
  scope         = var.app_gateway_id
  force_reapply = var.force_reapply
}
