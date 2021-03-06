# name: SecurityGroupの名前
# description: SecurityGroupの説明
# vpc_id: SecurityGroupリソースを作成するVPCを指定
# egress: SecurityGroupから外に出る通信のポートの範囲と対象IP

resource "aws_security_group" "instance" {
  name        = "instance"
  description = "instance sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb" {
  name        = "container-era-alb"
  description = "http and https"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "TCP"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # httpsでのアクセス許可
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name = "container-era-db"
  description = "DB"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [
      # ECSインスタンスのSGからのみの接続を許可
      aws_security_group.instance.id
    ]
  }
}
