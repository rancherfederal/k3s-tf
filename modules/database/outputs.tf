output "datastore_endpoint" {
  value = "mysql://${aws_db_instance.this.username}:${aws_db_instance.this.password}@tcp(${aws_db_instance.this.endpoint})/${aws_db_instance.this.name}"
}

output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.name
}

output "sg" {
  value = aws_security_group.this.id
}

output "username" {
  value = aws_db_instance.this.username
}

output "password" {
  value = aws_db_instance.this.password
}