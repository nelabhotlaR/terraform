package test
import "fmt"

import (
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"testing"
)

type Payload struct {
	Name string
}

func TestBasicLambdaFunction(t *testing.T) {
	t.Parallel()

	awsRegion := "ap-south-1"
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/terraform-aws-lambda-pto-detector",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	functionName := terraform.Output(t, terraformOptions, "lambda_function")
	fmt.Print("this is testtt: ", functionName)

	response := aws.InvokeFunction(t, awsRegion, functionName, Payload{Name: "World"})
	

	assert.Equal(t, `"Welome to terraform"`, string(response))

}