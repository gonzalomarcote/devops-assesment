provider "aws" {
  region  = var.region
}


terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-my-cool-terraform-bucket"
    key     = "terraform-state/my-cool-terraform-bucket.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    acl     = "bucket-owner-full-control"
  }
}

// ---------------- IAM Policy definition and role creation ---------------------

resource "aws_iam_policy" "ciPolicy" {
  name = "${terraform.workspace}-ci-policy"
  policy = data.aws_iam_policy_document.ciPolicyDoc.json
}

data "aws_iam_policy_document" "ciPolicyDoc" {
  statement {
    sid = "doNothing"

    actions = []

    resources = []
  }
}

resource "aws_iam_role" "ciRole" {
  name = "${terraform.workspace}-ci-role"
  assume_role_policy = data.aws_iam_policy_document.assumeRoleIam.json
}

data "aws_iam_policy_document" "assumeRoleIam" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole"
    ]

    resources = ["arn:aws:iam::0881XXXXXX:*"]
  }
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.ciRole.name
  policy_arn = aws_iam_policy.ciPolicy.arn
}

// ---------------- IAM Policy add to a new group and user belonging to that group ---------------------

resource "aws_iam_group" "coolGroup" {
  name = "coolGroup"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "coolGroupPolicy" {
  group = aws_iam_group.coolGroup.name
  policy_arn = aws_iam_policy.ciPolicy.arn
}

resource "aws_iam_user_group_membership" "coolGroupUsers" {
  user = "gonzo"

  groups = [
    "coolGroup",
  ]
}
