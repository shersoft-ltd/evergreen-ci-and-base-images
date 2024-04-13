# evergreen-ci-and-base-images

This repo accompanies [a blog post on jSherz.com] that describes how to keep
Docker base images or those used for CI/CD up-to-date automatically.

[a blog post on jSherz.com]: https://jsherz.com/aws/docker/2024/04/13/keeping-base-docker-images-up-to-date.html

## GitHub Workflows example

See `./github/workflows/build.yml`.

## CodePipeline/CodeBuild example

See `./codebuild-*.yml` and also the Terraform code in `./pipeline.tf`.
