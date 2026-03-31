#####################################
# VARIABLES
#####################################

variable "llm_deployment_name" {
  type    = string
  default = "davila-hf-lab"
}

variable "instance_type" {
  type    = string
  default = "g4dn.xlarge"
}

variable "key_name" {
  type = string
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "model_id" {
  type    = string
  default = "Qwen/Qwen2.5-1.5B-Instruct"
}

#####################################
# AMI UBUNTU DLAMI GPU
#####################################

data "aws_ssm_parameter" "dlami_gpu_ubuntu_2204" {
  name = "/aws/service/deeplearning/ami/x86_64/base-oss-nvidia-driver-gpu-ubuntu-22.04/latest/ami-id"
}

#####################################
# IAM ROLE EC2
#####################################

resource "aws_iam_role" "ec2_role" {
  name = "${var.llm_deployment_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.llm_deployment_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

#####################################
# SECURITY GROUP
#####################################

resource "aws_security_group" "llm_vm_sg" {
  name        = "${var.llm_deployment_name}-sg"
  description = "Security group for HF LLM lab"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "LLM API"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#####################################
# EC2 LAB
#####################################

resource "aws_instance" "hf_llm_vm" {
  ami                         = data.aws_ssm_parameter.dlami_gpu_ubuntu_2204.value
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.llm_vm_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 120
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y python3-pip python3-venv git

    mkdir -p /opt/llm
    cd /opt/llm

    python3 -m venv .venv
    source .venv/bin/activate

    pip install --upgrade pip
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
    pip install transformers accelerate bitsandbytes fastapi uvicorn

    cat > /opt/llm/app.py <<'PYEOF'
from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig
import torch
import os

MODEL_ID = os.getenv("MODEL_ID", "${var.model_id}")

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_use_double_quant=True
)

tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
model = AutoModelForCausalLM.from_pretrained(
    MODEL_ID,
    device_map="auto",
    quantization_config=bnb_config,
    torch_dtype=torch.bfloat16,
)

app = FastAPI()

class PromptRequest(BaseModel):
    prompt: str
    max_new_tokens: int = 128

@app.get("/health")
def health():
    return {"status": "ok", "model": MODEL_ID}

@app.post("/generate")
def generate(req: PromptRequest):
    messages = [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": req.prompt},
    ]

    text = tokenizer.apply_chat_template(
        messages,
        tokenize=False,
        add_generation_prompt=True
    )

    inputs = tokenizer(text, return_tensors="pt").to(model.device)

    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=req.max_new_tokens,
            temperature=0.7,
            do_sample=True
        )

    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return {"response": response}
PYEOF

    cat > /etc/systemd/system/llm-api.service <<'SERVICEEOF'
[Unit]
Description=HF LLM API
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/llm
Environment="MODEL_ID=${var.model_id}"
ExecStart=/opt/llm/.venv/bin/uvicorn app:app --host 0.0.0.0 --port 8000
Restart=always
User=root

[Install]
WantedBy=multi-user.target
SERVICEEOF

    systemctl daemon-reload
    systemctl enable llm-api
    systemctl start llm-api
  EOF

  tags = {
    Name = "${var.llm_deployment_name}-vm"
  }
}

#####################################
# EVENTBRIDGE SCHEDULER ROLE
#####################################

resource "aws_iam_role" "scheduler_role" {
  name = "${var.llm_deployment_name}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "scheduler_policy" {
  name = "${var.llm_deployment_name}-scheduler-policy"
  role = aws_iam_role.scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = aws_instance.hf_llm_vm.arn
      }
    ]
  })
}

#####################################
# START SCHEDULE
# Martes/Jueves 08:00 America/Bogota
#####################################

resource "aws_scheduler_schedule" "start_vm" {
  name                         = "${var.llm_deployment_name}-start"
  schedule_expression          = "cron(0 8 ? * TUE,THU *)"
  schedule_expression_timezone = "America/Bogota"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler_role.arn

    input = jsonencode({
      InstanceIds = [aws_instance.hf_llm_vm.id]
    })
  }
}

#####################################
# STOP SCHEDULE
# Martes/Jueves 17:00 America/Bogota
#####################################

resource "aws_scheduler_schedule" "stop_vm" {
  name                         = "${var.llm_deployment_name}-stop"
  schedule_expression          = "cron(0 17 ? * TUE,THU *)"
  schedule_expression_timezone = "America/Bogota"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler_role.arn

    input = jsonencode({
      InstanceIds = [aws_instance.hf_llm_vm.id]
    })
  }
}

#####################################
# OUTPUTS
#####################################

output "instance_id" {
  value = aws_instance.hf_llm_vm.id
}

output "public_ip" {
  value = aws_instance.hf_llm_vm.public_ip
}

output "health_url" {
  value = "http://${aws_instance.hf_llm_vm.public_ip}:8000/health"
}

output "generate_url" {
  value = "http://${aws_instance.hf_llm_vm.public_ip}:8000/generate"
}