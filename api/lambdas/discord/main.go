package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/expression"
)

type IoTData struct {
	DeviceID    string  `json:"device_id"`
	Timestamp   int64   `json:"timestamp"`
	Temperature float64 `json:"temperature"`
	Humidity    float64 `json:"humidity"`
}

// Sends a message to Discord using the provided webhook URL
func sendToDiscord(webhookURL, message string) error {
	payload := map[string]string{
		"content": message,
	}
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	resp, err := http.Post(webhookURL, "application/json", bytes.NewBuffer(payloadBytes))
	if err != nil {
		return fmt.Errorf("failed to send message to Discord: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent {
		return fmt.Errorf("discord API returned status: %d", resp.StatusCode)
	}

	return nil
}

// The main Lambda handler
func handler(ctx context.Context, event map[string]interface{}) (string, error) {
	// Retrieve environment variables
	webhookURL := os.Getenv("DISCORD_WEBHOOK_URL")
	if webhookURL == "" {
		return "", fmt.Errorf("DISCORD_WEBHOOK_URL is not set in environment variables")
	}

	tableName := os.Getenv("TABLE_NAME")
	if tableName == "" {
		return "", fmt.Errorf("TABLE_NAME is not set in environment variables")
	}

	// Create DynamoDB client
	sess := session.Must(session.NewSession())
	svc := dynamodb.New(sess)

	// Define DynamoDB Scan
	expr, err := expression.NewBuilder().
		WithProjection(expression.NamesList(
			expression.Name("device_id"),
			expression.Name("timestamp"),
			expression.Name("temperature"),
			expression.Name("humidity"),
		)).
		Build()
	if err != nil {
		return "", fmt.Errorf("failed to build DynamoDB expression: %w", err)
	}

	// Perform a Scan operation to fetch all records
	input := &dynamodb.ScanInput{
		TableName:                aws.String(tableName),
		ExpressionAttributeNames: expr.Names(),
		ProjectionExpression:     expr.Projection(),
	}

	result, err := svc.Scan(input)
	if err != nil {
		return "", fmt.Errorf("failed to scan DynamoDB: %w", err)
	}
	if len(result.Items) == 0 {
		return "", fmt.Errorf("no items found in DynamoDB table")
	}

	// Find the record with the highest timestamp
	var latestItem IoTData
	var highestTimestamp int64
	for _, item := range result.Items {
		var record IoTData
		err := dynamodbattribute.UnmarshalMap(item, &record)
		if err != nil {
			log.Printf("Failed to unmarshal record: %v", err)
			continue
		}

		if record.Timestamp > highestTimestamp {
			highestTimestamp = record.Timestamp
			latestItem = record
		}
	}

	// If no valid record is found
	if highestTimestamp == 0 {
		return "", fmt.Errorf("no valid records found with a timestamp")
	}

	// Format the message and send to Discord
	message := fmt.Sprintf(
		"Device: %s\nTimestamp: %d\nTemperature: %.2f°C\nHumidity: %.2f%%",
		latestItem.DeviceID, latestItem.Timestamp, latestItem.Temperature, latestItem.Humidity,
	)
	log.Printf("Sending message: %s", message)

	err = sendToDiscord(webhookURL, message)
	if err != nil {
		return "", fmt.Errorf("failed to send message for device %s: %w", latestItem.DeviceID, err)
	}
	return "Latest IoT data pushed to Discord", nil
}

func main() {
	lambda.Start(handler)
}
