module "unlock" {
  source        = "../"
  lock_name     = var.lock_name
  scope         = var.virtual_machine_id
  force_reapply = var.force_reapply
}
