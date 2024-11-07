
variable "ingress_rules" {
  description = "List of ingress rules for HTTP and HTTPS"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "ssh_key" {
  description = "SSH key pair in AWS"
  type        = string
}

