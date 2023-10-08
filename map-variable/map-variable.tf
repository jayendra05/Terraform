# variable "userage" {
#   type = map
#   default = {
#     jayendra=20
#     yatindra=18
#   }
# }

variable "userage" {
  type = number
}
variable "username" {
  type = string
}


output "userage" {
#   value = "my name is jayendra and my age is ${lookup(var.userage,"jayendra")}"
#    value = "my name is jayendra and my age is ${lookup(var.userage,"${var.username}")}"
   value = "my name is ${var.username} and my age is ${var.userage})}"


}