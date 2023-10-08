variable users {
    type = list
}

output printfirst {
  value = "first user is ${var.users[0]}"
}