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

// Sends a warning embed message to Discord using the provided webhook URL
func sendToDiscord(webhookURL string, latestItem IoTData, warning, warningDetail string) error {
	payload := map[string]interface{}{
		"embeds": []map[string]interface{}{
			{
				"title":       "⚠️ **IoT Device Warning** ⚠️",
				"description": fmt.Sprintf("Detected value %s\n%s", warningDetail, warning),
				"color":       16711680, // Red color
				"fields": []map[string]interface{}{
					{"name": "Device ID", "value": latestItem.DeviceID, "inline": true},
					{"name": "Timestamp", "value": fmt.Sprintf("%d", latestItem.Timestamp), "inline": true},
					{"name": "Temperature", "value": fmt.Sprintf("%.2f°C", latestItem.Temperature), "inline": true},
					{"name": "Humidity", "value": fmt.Sprintf("%.2f%%", latestItem.Humidity), "inline": true},
				},
			},
		},
	}

	// Convert the payload to JSON
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	// Send the payload to Discord
	resp, err := http.Post(webhookURL, "application/json", bytes.NewBuffer(payloadBytes))
	if err != nil {
		return fmt.Errorf("failed to send message to Discord: %w", err)
	}
	defer resp.Body.Close()

	// Check the response status
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

	// Define threshold values
	const minTemperature = 10.0
	const maxTemperature = 30.0
	const minHumidity = 40.0
	const maxHumidity = 80.0

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

	// Check for warnings and include threshold values
	var warning, warningDetail string
	if latestItem.Temperature < minTemperature {
		warning = fmt.Sprintf("Temperature: %.2f°C", latestItem.Temperature)
		warningDetail = fmt.Sprintf("below the minimum threshold of %.2f°C.", minTemperature)
	} else if latestItem.Temperature > maxTemperature {
		warning = fmt.Sprintf("Temperature: %.2f°C", latestItem.Temperature)
		warningDetail = fmt.Sprintf("above the maximum threshold of %.2f°C.", maxTemperature)
	} else if latestItem.Humidity < minHumidity {
		warning = fmt.Sprintf("Humidity: %.2f%%", latestItem.Humidity)
		warningDetail = fmt.Sprintf("below the minimum threshold of %.2f%%.", minHumidity)
	} else if latestItem.Humidity > maxHumidity {
		warning = fmt.Sprintf("Humidity: %.2f%%", latestItem.Humidity)
		warningDetail = fmt.Sprintf("above the maximum threshold of %.2f%%.", maxHumidity)
	}

	// Only send a message if a warning exists
	if warning != "" {
		err = sendToDiscord(webhookURL, latestItem, warning, warningDetail)
		if err != nil {
			return "", fmt.Errorf("failed to send warning to Discord: %w", err)
		}
		log.Printf("Warning sent to Discord for device %s", latestItem.DeviceID)
	} else {
		log.Printf("No warnings for device %s", latestItem.DeviceID)
	}

	return "IoT data processed", nil
}

func main() {
	lambda.Start(handler)
}
