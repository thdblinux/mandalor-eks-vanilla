locals {
  kms_key_arn = var.enable_kms_encryption ? (
    var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.this[0].arn
  ) : null
}

resource "aws_kms_key" "this" {
  count       = var.enable_kms_encryption && var.kms_key_arn == "" ? 1 : 0
  description = "KMS key para encriptação de secrets do cluster ${var.cluster_name}"
  tags        = var.tags
}

resource "aws_kms_alias" "this" {
  count         = var.enable_kms_encryption && var.kms_key_arn == "" ? 1 : 0
  name          = "alias/${var.cluster_name}"
  target_key_id = aws_kms_key.this[0].id
}
