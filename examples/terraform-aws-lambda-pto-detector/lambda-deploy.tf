
locals{
    lambda_zip_location = "outputs/pto_detector_dummy.zip"
}

data "archive_file" "pto_detector_dummy" {
  type        = "zip"
  source_file = "pto_detector_dummy.py"
  output_path = "${local.lambda_zip_location}"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${local.lambda_zip_location}"
  function_name = "pto_detector_dummy"
  role          = "arn:aws:iam::285993504765:role/lambda-deployer"
  handler       = "pto_detector_dummy.main_handler"

  source_code_hash = "${filebase64sha256(local.lambda_zip_location)}"
  runtime = "python3.7"
}
