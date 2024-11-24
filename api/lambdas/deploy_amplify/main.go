package main

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/amplify"
)

// DeploymentRequest represents the input for the Lambda function
type DeploymentRequest struct {
	AppID      string `json:"app_id"`
	BranchName string `json:"branch_name"`
	SourceURL  string `json:"source_url"`
}

// DeploymentResponse represents the output from the deployment
type DeploymentResponse struct {
	JobID      string `json:"job_id"`
	StatusCode string `json:"status_code"`
	Message    string `json:"message"`
}

func handler(ctx context.Context, req DeploymentRequest) (DeploymentResponse, error) {
	// Create AWS session
	sess := session.Must(session.NewSession())
	svc := amplify.New(sess, aws.NewConfig().WithRegion(os.Getenv("AWS_REGION")))

	// Validate input
	if req.AppID == "" || req.BranchName == "" || req.SourceURL == "" {
		return DeploymentResponse{}, fmt.Errorf("app_id, branch_name, and source_url are required")
	}

	// Start deployment
	input := &amplify.StartDeploymentInput{
		AppId:      aws.String(req.AppID),
		BranchName: aws.String(req.BranchName),
		SourceUrl:  aws.String(req.SourceURL),
	}

	result, err := svc.StartDeployment(input)
	if err != nil {
		return DeploymentResponse{}, fmt.Errorf("failed to start deployment: %w", err)
	}

	response := DeploymentResponse{
		JobID:      aws.StringValue(result.JobSummary.JobId),
		StatusCode: "200",
		Message:    "Deployment started successfully",
	}

	return response, nil
}

func main() {
	lambda.Start(handler)
}
