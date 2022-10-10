provider "aws" {
  region = "${var.aws_region}"
}

provider "archive" {
}

data "archive_file" "zip" {
  type        = "zip"
  source_file  = "${local.input_file}"
  output_path = "outputs/lambda_file.zip"
}

data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir  = "${local.requirements_directory}"
  output_path = "outputs/requirements.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${data.archive_file.lambda_layer_zip.output_path}"
  layer_name = "${var.lambda_layer_name}"

  compatible_runtimes = ["python3.6","python3.7","python3.8"]
}

resource "aws_lambda_function" "lambda" {
  filename         = "${data.archive_file.zip.output_path}"
  #source_code_hash = "${data.archive_file.zip.output_base64sha256}"
  function_name    = "${var.function_name}"
  role             = "arn:aws:iam::285993504765:role/lambda-deployer"
  handler          = "${var.handler}"
  runtime          = "python3.7"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  tracing_config {
    mode = "Active"
  }
}

