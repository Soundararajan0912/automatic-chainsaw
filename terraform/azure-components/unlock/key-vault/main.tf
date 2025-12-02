module "unlock" {
  source        = "../"
  lock_name     = var.lock_name
  scope         = var.key_vault_id
  force_reapply = var.force_reapply
}
