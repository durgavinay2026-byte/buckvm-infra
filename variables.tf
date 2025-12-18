variable "vm_name" {
	type    = string
	default = "hello-vm"
}

variable "vm_machine_type" {
	type    = string
	default = "e2-medium"
}

variable "create_kms" {
	type    = bool
	default = true
}

variable "tags" {
	type    = list(string)
	default = ["http-server"]
}