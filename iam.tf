resource "aws_iam_role" "role" {
  name = "${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "document" {
  // ebs
  statement {
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:AttachVolume",
    ]

    resources = ["*"]
  }

  // autoscaling
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "autoscaling:DescribeAutoScalingInstances",
    ]

    resources = ["*"]
  }

  // eni
  statement {
    actions = [
      "ec2:DescribeNetworkInterfaces",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:DetachNetworkInterface",
      "ec2:AttachNetworkInterface",
    ]

    resources = ["*"]
  }

  // kms
  statement {
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:Describe*",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    resources = ["*"]
  }

  // secure bucket
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket}",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket}",
      "arn:aws:s3:::${var.bucket}/*",
    ]
  }
}

// create our iam_policy
resource "aws_iam_policy" "policy" {
  name   = "${var.name}"
  policy = "${data.aws_iam_policy_document.document.json}"
}

// attach iam_policy to mail role
resource "aws_iam_role_policy_attachment" "attachment" {
  role       = "${var.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

// create profile from role
resource "aws_iam_instance_profile" "profile" {
  role = "${aws_iam_role.role.name}"
  name = "${var.name}"
}
