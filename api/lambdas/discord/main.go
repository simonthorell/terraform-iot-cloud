package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
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
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("discord API returned status: %d, body: %s", resp.StatusCode, string(body))
	}

	return nil
}

// The main Lambda handler
func handler(ctx context.Context, event map[string]interface{}) (string, error) {
	// Retrieve environment variables
	webhookURL := os.Getenv("DISCORD_WEBHOOK_URL")
	if webhookURL == "" {
		log.Printf("DISCORD_WEBHOOK_URL is not set")
		return "", fmt.Errorf("DISCORD_WEBHOOK_URL is not set in environment variables")
	}

	tableName := os.Getenv("TABLE_NAME")
	if tableName == "" {
		log.Printf("TABLE_NAME is not set")
		return "", fmt.Errorf("TABLE_NAME is not set in environment variables")
	}

	// Create DynamoDB client
	sess := session.Must(session.NewSession())
	svc := dynamodb.New(sess)

	// Perform DynamoDB Scan
	input := &dynamodb.ScanInput{
		TableName: aws.String(tableName),
	}
	result, err := svc.Scan(input)
	if err != nil {
		log.Printf("Failed to scan DynamoDB: %v", err)
		return "", fmt.Errorf("failed to scan DynamoDB: %w", err)
	}
	log.Printf("Raw DynamoDB Scan Result: %v", result.Items)

	// Unmarshal scan results
	var items []IoTData
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, &items)
	if err != nil {
		log.Printf("Failed to unmarshal DynamoDB items: %v", err)
		return "", fmt.Errorf("failed to unmarshal scan results: %w", err)
	}
	log.Printf("Unmarshalled Items: %+v", items)

	// Send messages to Discord
	for _, item := range items {
		log.Printf("Processing item: %+v", item)
		message := fmt.Sprintf(
			"Device: %s\nTimestamp: %d\nTemperature: %.2f°C\nHumidity: %.2f%%",
			item.DeviceID, item.Timestamp, item.Temperature, item.Humidity,
		)
		log.Printf("Sending message: %s", message)

		err := sendToDiscord(webhookURL, message)
		if err != nil {
			log.Printf("Failed to send message for device %s: %v", item.DeviceID, err)
			continue
		}
		log.Printf("Successfully sent message for device %s", item.DeviceID)
	}

	return "IoT data pushed to Discord", nil
}

func main() {
	lambda.Start(handler)
}

// package main

// import (
// 	"bytes"
// 	"context"
// 	"encoding/json"
// 	"fmt"
// 	"log"
// 	"net/http"
// 	"os"

// 	"github.com/aws/aws-lambda-go/lambda"
// 	"github.com/aws/aws-sdk-go/aws"
// 	"github.com/aws/aws-sdk-go/aws/session"
// 	"github.com/aws/aws-sdk-go/service/dynamodb"
// 	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
// )

// type IoTData struct {
// 	DeviceID    string  `json:"device_id"`
// 	Timestamp   int64   `json:"timestamp"`
// 	Temperature float64 `json:"temperature"`
// 	Humidity    float64 `json:"humidity"`
// }

// func sendToDiscord(webhookURL, message string) error {
// 	payload := map[string]string{
// 		"content": message,
// 	}
// 	payloadBytes, err := json.Marshal(payload)
// 	if err != nil {
// 		return fmt.Errorf("failed to marshal payload: %w", err)
// 	}

// 	resp, err := http.Post(webhookURL, "application/json", bytes.NewBuffer(payloadBytes))
// 	if err != nil {
// 		return fmt.Errorf("failed to send message to Discord: %w", err)
// 	}
// 	defer resp.Body.Close()

// 	if resp.StatusCode != http.StatusNoContent {
// 		return fmt.Errorf("discord API returned status: %d", resp.StatusCode)
// 	}

// 	return nil
// }

// func handler(ctx context.Context, event map[string]interface{}) (string, error) {
// 	// Retrieve environment variables
// 	webhookURL := os.Getenv("DISCORD_WEBHOOK_URL")
// 	if webhookURL == "" {
// 		log.Printf("DISCORD_WEBHOOK_URL is not set")
// 		return "", fmt.Errorf("DISCORD_WEBHOOK_URL is not set in environment variables")
// 	}
// 	log.Printf("DISCORD_WEBHOOK_URL: %s", webhookURL)

// 	tableName := os.Getenv("TABLE_NAME")
// 	if tableName == "" {
// 		log.Printf("TABLE_NAME is not set")
// 		return "", fmt.Errorf("TABLE_NAME is not set in environment variables")
// 	}
// 	log.Printf("TABLE_NAME: %s", tableName)

// 	// Create DynamoDB client
// 	sess := session.Must(session.NewSession())
// 	svc := dynamodb.New(sess)

// 	// Perform DynamoDB Scan
// 	input := &dynamodb.ScanInput{
// 		TableName: aws.String(tableName),
// 	}
// 	result, err := svc.Scan(input)
// 	if err != nil {
// 		log.Printf("Failed to scan DynamoDB: %v", err)
// 		return "", fmt.Errorf("failed to scan DynamoDB: %w", err)
// 	}
// 	log.Printf("Raw DynamoDB Scan Result: %v", result.Items)

// 	// Unmarshal scan results
// 	var items []IoTData
// 	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, &items)
// 	if err != nil {
// 		log.Printf("Failed to unmarshal DynamoDB items: %v", err)
// 		return "", fmt.Errorf("failed to unmarshal scan results: %w", err)
// 	}
// 	log.Printf("Unmarshalled Items: %+v", items)

// 	// Send messages to Discord
// 	for _, item := range items {
// 		log.Printf("Processing item: %+v", item)
// 		message := fmt.Sprintf(
// 			"Device: %s\nTimestamp: %d\nTemperature: %.2f°C\nHumidity: %.2f%%",
// 			item.DeviceID, item.Timestamp, item.Temperature, item.Humidity,
// 		)
// 		log.Printf("Sending message: %s", message)

// 		err := sendToDiscord(webhookURL, message)
// 		if err != nil {
// 			log.Printf("Failed to send message for device %s: %v", item.DeviceID, err)
// 			continue
// 		}
// 		log.Printf("Successfully sent message for device %s", item.DeviceID)
// 	}

// 	return "IoT data pushed to Discord", nil
// }

// func handler(ctx context.Context, event map[string]interface{}) (string, error) {
// 	// Get the table name from environment variables
// 	tableName := os.Getenv("TABLE_NAME")
// 	if tableName == "" {
// 		return "", fmt.Errorf("environment variable TABLE_NAME not set")
// 	}

// 	// Get Discord webhook URL from environment variables
// 	webhookURL := os.Getenv("DISCORD_WEBHOOK_URL")
// 	if webhookURL == "" {
// 		return "", fmt.Errorf("DISCORD_WEBHOOK_URL is not set in environment variables")
// 	}

// 	// Create DynamoDB client
// 	sess := session.Must(session.NewSession())
// 	svc := dynamodb.New(sess)

// 	// Define the Scan input parameters
// 	input := &dynamodb.ScanInput{
// 		TableName: aws.String(tableName),
// 	}

// 	// Perform the DynamoDB Scan
// 	result, err := svc.Scan(input)
// 	if err != nil {
// 		return "", fmt.Errorf("failed to scan DynamoDB: %w", err)
// 	}

// 	// Unmarshal the scan results into IoTData structs
// 	var items []IoTData
// 	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, &items)
// 	if err != nil {
// 		return "", fmt.Errorf("failed to unmarshal scan results: %w", err)
// 	}

// 	// Send each IoTData item to Discord
// 	for _, item := range items {
// 		message := fmt.Sprintf(
// 			"Device: %s\nTimestamp: %d\nTemperature: %.2f°C\nHumidity: %.2f%%",
// 			item.DeviceID, item.Timestamp, item.Temperature, item.Humidity,
// 		)

// 		err := sendToDiscord(webhookURL, message)
// 		if err != nil {
// 			log.Printf("Failed to send message for device %s: %v", item.DeviceID, err)
// 			continue
// 		}
// 		log.Printf("Successfully sent message for device %s", item.DeviceID)
// 	}

// 	return "IoT data pushed to Discord", nil
// }

// func main() {
// 	lambda.Start(handler)
// }
