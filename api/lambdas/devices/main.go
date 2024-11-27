package main

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

type IoTData struct {
	DeviceID string `json:"device_id"`
	Owner    string `json:"owner"`
	Status   string `json:"status"`
}

func handler(ctx context.Context) (interface{}, error) {
	tableName := os.Getenv("TABLE_NAME")
	if tableName == "" {
		return nil, fmt.Errorf("TABLE_NAME environment variable not set")
	}

	// Create DynamoDB client
	sess := session.Must(session.NewSession())
	svc := dynamodb.New(sess)

	// Define the scan input parameters
	input := &dynamodb.ScanInput{
		TableName: aws.String(tableName),
	}

	// Make the DynamoDB Scan API call
	result, err := svc.Scan(input)
	if err != nil {
		return nil, fmt.Errorf("failed to scan DynamoDB: %w", err)
	}

	var items []IoTData
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, &items)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal Scan result items: %w", err)
	}

	return items, nil
}

func main() {
	lambda.Start(handler)
}
