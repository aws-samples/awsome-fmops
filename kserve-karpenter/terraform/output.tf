
output "REGION" {
  value = var.region
}
output "CLUSTER_NAME" {
  value = var.name
}
output "BUCKET_NAME" {
  value = aws_s3_bucket.data_bucket.id
}

output "INGRESS_HOST" {
  value = var.ingress_host
}

output "INGRESS_PORT" {
  value = var.ingress_port
}
