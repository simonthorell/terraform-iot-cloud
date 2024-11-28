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
	DeviceID  string `json:"device_id"`
	Timestamp int64  `json:"timestamp"`
	Data      string `json:"data"` // Additional data field, adjust as necessary
}

type Request struct {
	DeviceID string `json:"device_id"`
}

type APIResponse struct {
	StatusCode int               `json:"statusCode"`
	Headers    map[string]string `json:"headers"`
	Body       string            `json:"body"`
}

func handler(ctx context.Context, req Request) (APIResponse, error) {
	// Validate request
	if req.DeviceID == "" {
		return APIResponse{
			StatusCode: 400,
			Headers:    map[string]string{"Content-Type": "application/json"},
			Body:       `{"error": "Missing device_id in request"}`,
		}, nil
	}

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

	// Define the query input parameters
	input := &dynamodb.QueryInput{
		TableName: aws.String(tableName),
		KeyConditions: map[string]*dynamodb.Condition{
			"device_id": {
				ComparisonOperator: aws.String("EQ"),
				AttributeValueList: []*dynamodb.AttributeValue{
					{
						S: aws.String(req.DeviceID),
					},
				},
			},
		},
	}

	// Perform the DynamoDB Query
	result, err := svc.Query(input)
	if err != nil {
		return APIResponse{
			StatusCode: 500,
			Headers:    map[string]string{"Content-Type": "application/json"},
			Body:       fmt.Sprintf(`{"error": "Failed to query DynamoDB: %s"}`, err.Error()),
		}, nil
	}

	// Unmarshal the query results into IoTData structs
	var items []IoTData
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, &items)
	if err != nil {
		return APIResponse{
			StatusCode: 500,
			Headers:    map[string]string{"Content-Type": "application/json"},
			Body:       fmt.Sprintf(`{"error": "Failed to unmarshal query results: %s"}`, err.Error()),
		}, nil
	}

	// Marshal the results into a JSON string
	responseBody, err := json.Marshal(items)
	if err != nil {
		return APIResponse{
			StatusCode: 500,
			Headers:    map[string]string{"Content-Type": "application/json"},
			Body:       fmt.Sprintf(`{"error": "Failed to marshal response: %s"}`, err.Error()),
		}, nil
	}

	// Return a successful response
	return APIResponse{
		StatusCode: 200,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(responseBody),
	}, nil
}

func main() {
	lambda.Start(handler)
}
