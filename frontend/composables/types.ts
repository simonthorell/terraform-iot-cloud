// Define the Device type
export interface Device {
    device_id: string;
    owner: string;
    status: string;
  }

export interface IotData {
    device_id: string;
    timestamp: string;
    temperature: number;
    humidity: number;
}