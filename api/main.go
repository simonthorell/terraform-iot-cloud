package main

import (
	"context"
	// "encoding/json"
	"fmt"
	// "log"
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

func handler(ctx context.Context, req Request) (interface{}, error) {
	tableName := os.Getenv("TABLE_NAME")
	if tableName == "" {
		return nil, fmt.Errorf("TABLE_NAME environment variable not set")
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

	// Make the DynamoDB Query API call
	result, err := svc.Query(input)
	if err != nil {
		return nil, fmt.Errorf("failed to query DynamoDB: %w", err)
	}

	var items []IoTData
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, &items)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal Query result items: %w", err)
	}

	return items, nil
}

func main() {
	lambda.Start(handler)
}
