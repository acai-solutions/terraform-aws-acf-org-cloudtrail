package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestExampleComplete(t *testing.T) {
	t.Log("Starting Sample Module test")

	terraformDir := "../../examples/complete"
	stateKey := "terratest/terraform-aws-acf-org-cloudtrail.tfstate"
	backendConfig := loadBackendConfig(t, stateKey)

	// Step 1: Create the CICD provisioner IAM roles in the org-mgmt and core-logging accounts.
	terraformPreparation := &terraform.Options{
		TerraformBinary: getHclBinary(),
		TerraformDir:    terraformDir,
		NoColor:         false,
		Lock:            true,
		BackendConfig:   backendConfig,
		Reconfigure:     true,
		Targets: []string{
			"module.create_provisioner_admin",
			"module.create_provisioner_bucket",
		},
	}
	defer terraform.Destroy(t, terraformPreparation)
	terraform.InitAndApply(t, terraformPreparation)

	// Step 2: Apply the full example, assuming the provisioner roles created above.
	terraformModule := &terraform.Options{
		TerraformBinary: getHclBinary(),
		TerraformDir:    terraformDir,
		NoColor:         false,
		Lock:            true,
		BackendConfig:   backendConfig,
		Reconfigure:     true,
	}
	defer terraform.Destroy(t, terraformModule)
	terraform.InitAndApply(t, terraformModule)

	// Retrieve the 'test_success' output (warnings stripped)
	testSuccessOutput := outputClean(t, terraformModule, "test_success")
	t.Logf("testSuccessOutput: %s", testSuccessOutput)

	// Assert that 'test_success' equals "true"
	assert.Equal(t, "true", testSuccessOutput, "The test_success output is not true")
}
