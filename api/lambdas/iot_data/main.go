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

type IoTData struct {
	DeviceID    string  `json:"device_id"`
	Timestamp   int64   `json:"timestamp"`
	Temperature float64 `json:"temperature"`
	Humidity    float64 `json:"humidity"`
}

type APIResponse struct {
	StatusCode int               `json:"statusCode"`
	Headers    map[string]string `json:"headers"`
	Body       string            `json:"body"`
}

func handler(ctx context.Context, event map[string]interface{}) (APIResponse, error) {
	// Common headers
	headers := map[string]string{
		"Content-Type":                     "application/json",
		"Access-Control-Allow-Origin":      "*", // Allow all origins for CORS
		"Access-Control-Allow-Methods":     "GET, OPTIONS",
		"Access-Control-Allow-Headers":     "Content-Type",
		"Access-Control-Allow-Credentials": "true", // If needed
	}

	// Get the table name from environment variables
	tableName := os.Getenv("TABLE_NAME")
	if tableName == "" {
		return APIResponse{
			StatusCode: 500,
			Headers:    headers,
			Body:       `{"error": "Environment variable TABLE_NAME not set"}`,
		}, nil
	}

	// Create DynamoDB client
	sess := session.Must(session.NewSession())
	svc := dynamodb.New(sess)

	// Define the Scan input parameters
	input := &dynamodb.ScanInput{
		TableName: aws.String(tableName),
	}

	// Perform the DynamoDB Scan
	result, err := svc.Scan(input)
	if err != nil {
		return APIResponse{
			StatusCode: 500,
			Headers:    headers,
			Body:       fmt.Sprintf(`{"error": "Failed to scan DynamoDB: %s"}`, err.Error()),
		}, nil
	}

	// Unmarshal the scan results into IoTData structs
	var items []IoTData
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, &items)
	if err != nil {
		return APIResponse{
			StatusCode: 500,
			Headers:    headers,
			Body:       fmt.Sprintf(`{"error": "Failed to unmarshal scan results: %s"}`, err.Error()),
		}, nil
	}

	// Marshal the results into a JSON string
	responseBody, err := json.Marshal(items)
	if err != nil {
		return APIResponse{
			StatusCode: 500,
			Headers:    headers,
			Body:       fmt.Sprintf(`{"error": "Failed to marshal response: %s"}`, err.Error()),
		}, nil
	}

	// Return a successful response
	return APIResponse{
		StatusCode: 200,
		Headers:    headers,
		Body:       string(responseBody),
	}, nil
}

func main() {
	lambda.Start(handler)
}
