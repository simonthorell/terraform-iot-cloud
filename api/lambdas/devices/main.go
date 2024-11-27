package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

// IoTData defines the structure of the data from DynamoDB
type IoTData struct {
	DeviceID string `json:"device_id"`
	Owner    string `json:"owner"`
	Status   string `json:"status"`
}

// APIResponse is the required response format for Lambda proxy integration
type APIResponse struct {
	StatusCode int               `json:"statusCode"`
	Headers    map[string]string `json:"headers"`
	Body       string            `json:"body"`
}

func handler(ctx context.Context) (APIResponse, error) {
	// Get the table name from environment variables
	tableName := os.Getenv("TABLE_NAME")
	if tableName == "" {
		return APIResponse{
			StatusCode: 500,
			Headers:    map[string]string{"Content-Type": "application/json"},
			Body:       `{"error": "Environment variable TABLE_NAME not set"}`,
		}, nil
	}

	// Create DynamoDB client
	sess := session.Must(session.NewSession())
	svc := dynamodb.New(sess)

	// Define the scan input parameters
	input := &dynamodb.ScanInput{
		TableName: aws.String(tableName),
	}

	// Perform the DynamoDB Scan
	result, err := svc.Scan(input)
	if err != nil {
		return APIResponse{
			StatusCode: 500,
			Headers:    map[string]string{"Content-Type": "application/json"},
			Body:       fmt.Sprintf(`{"error": "Failed to scan DynamoDB: %s"}`, err.Error()),
		}, nil
	}

	// Unmarshal the scan results into IoTData structs
	var items []IoTData
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, &items)
	if err != nil {
		return APIResponse{
			StatusCode: 500,
			Headers:    map[string]string{"Content-Type": "application/json"},
			Body:       fmt.Sprintf(`{"error": "Failed to unmarshal DynamoDB results: %s"}`, err.Error()),
		}, nil
	}

	// Marshal the items into a JSON string
	responseBody, err := json.Marshal(items)
	if err != nil {
		return APIResponse{
			StatusCode: 500,
			Headers:    map[string]string{"Content-Type": "application/json"},
			Body:       fmt.Sprintf(`{"error": "Failed to marshal response: %s"}`, err.Error()),
		}, nil
	}

	// Return the success response
	return APIResponse{
		StatusCode: 200,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(responseBody),
	}, nil
}

func main() {
	lambda.Start(handler)
}
