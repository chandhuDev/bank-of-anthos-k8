resource "aws_key_pair" "key-pair" {
  key_name   = var.aws_key_pair_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgg3BIjDU6b5BMxrH1Vfv4KrPxnKmqvEZ92KHQjTz0mq/wKLVjnQgSnF3A8FIMAwIYelOSuD69POoxo9Ax4WPUiWJRBL67TvrXpT8h2/bWKhf5ms38SrvTQ1h9JdQe+B74FfZKXMGEr6hfrsgJJgKKHLJgYU0V/AXakSiCQCbvyA2NRXHKGV60cZZoJHB+Lgn8OqPWu5fJ4r+AUDWvKG/027e3MM3NXt3AwE8b45EFzqKj1KCShY3lK5+lZ0Nb5y/kWLtMAhG/tftVTDYiUrFHeVyamKbuWtHUoq0eq41A8B2veHfWBmKVwmOIU6uz4K7uur4xsifF5ilX+zKrtiEsJDYOM6LK9X9BJ6KwaRWBn4yyyfsXgxAvoMgPJpwyEi5jYZDKRxHoi6LS7OhAry1wlqheg2efpeUPGDbljAIldz/wXamBXQsUAjjFw09bl8skW7qc8KieAJb2Z9fwSPGMsrLcosx+vwYsKmAR5Zh8ha4+W6SNfC5C9xd8F3leX18fFMVuR6t8EmKAc/CzkibM7VHvfcfstFKh2RZFoZuC6U9ZQ3vURa5to5XmgYdHaov3VKCceMOOlqvopdk45K5k7ARcbvsP5Dy1Dxfec49mtQ87bBxEDo7YuXrMM+4pMOkC6JYNE59MtwZNQ/txkUjedWBzEmPLeeQmkKZi2iVwcQ== chandhu-eks"
}

resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  availability_zone           = var.az
  subnet_id                   = var.public_subnet_ids["us-east-2b"]
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg]
  key_name                    = aws_key_pair.key-pair.key_name

  user_data = templatefile("${path.module}/install.sh", {})


  tags = {
    Name = "ec2-jenkins"
  }
}
