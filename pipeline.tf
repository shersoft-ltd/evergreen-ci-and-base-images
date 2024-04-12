data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.resource_prefix}-codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    sid       = "GetAuthorizationToken"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ecr:GetAuthorizationToken"]
  }

  statement {
    sid    = "AllowPushingImagesToEcr"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchDeleteImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowUseOfCodePipelineSourcesAndArtifacts"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }

  statement {
    sid    = "AllowRunningBatchedJobs"
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  role   = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild.json
}

resource "aws_cloudwatch_log_group" "codebuild_build" {
  name = "${var.resource_prefix}-codebuild-build"

  retention_in_days = 30
}

resource "aws_codebuild_project" "build" {
  name         = "${var.resource_prefix}-build"
  service_role = aws_iam_role.codebuild.arn

  build_batch_config {
    service_role    = aws_iam_role.codebuild.arn
    timeout_in_mins = 10

    restrictions {
      compute_types_allowed  = ["BUILD_GENERAL1_SMALL"]
      maximum_builds_allowed = 100
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_build.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "codebuild-build.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"

    environment_variable {
      name  = "REGISTRY"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_cloudwatch_log_group" "codebuild_verify" {
  name = "${var.resource_prefix}-codebuild-verify"

  retention_in_days = 30
}

resource "aws_codebuild_project" "verify" {
  name         = "${var.resource_prefix}-verify"
  service_role = aws_iam_role.codebuild.arn

  build_batch_config {
    service_role    = aws_iam_role.codebuild.arn
    timeout_in_mins = 10

    restrictions {
      compute_types_allowed  = ["BUILD_GENERAL1_SMALL"]
      maximum_builds_allowed = 100
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_verify.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "codebuild-verify.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"

    environment_variable {
      name  = "REGISTRY"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_cloudwatch_log_group" "codebuild_publish" {
  name = "${var.resource_prefix}-codebuild-publish"

  retention_in_days = 30
}

resource "aws_codebuild_project" "publish" {
  name         = "${var.resource_prefix}-publish"
  service_role = aws_iam_role.codebuild.arn

  build_batch_config {
    service_role    = aws_iam_role.codebuild.arn
    timeout_in_mins = 10

    restrictions {
      compute_types_allowed  = ["BUILD_GENERAL1_SMALL"]
      maximum_builds_allowed = 100
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_publish.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "codebuild-publish.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"

    environment_variable {
      name  = "REGISTRY"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_codepipeline" "main" {
  name          = var.resource_prefix
  pipeline_type = "V2"
  role_arn      = aws_iam_role.codepipeline.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.repository
        BranchName       = var.default_branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName      = aws_codebuild_project.build.name,
        BatchEnabled     = true,
        CombineArtifacts = true,
      }
    }
  }

  stage {
    name = "Verify"

    action {
      name             = "Verify"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["verify_output"]
      version          = "1"

      configuration = {
        ProjectName      = aws_codebuild_project.verify.name,
        BatchEnabled     = true,
        CombineArtifacts = true,
      }
    }
  }

  stage {
    name = "Publish"

    action {
      name             = "Publish"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["publish_output"]
      version          = "1"

      configuration = {
        ProjectName      = aws_codebuild_project.publish.name,
        BatchEnabled     = true,
        CombineArtifacts = true,
      }
    }
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.resource_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "${var.resource_prefix}-codepipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github.arn]
  }

  statement {
    sid    = "AllowStartingBatches"
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}
