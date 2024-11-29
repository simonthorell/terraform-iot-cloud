import { ref } from "vue";
import config from "../.config/api-endpoints.json";

// Generic composable for fetching data from an API
export function useApi<T>(apiName: keyof typeof config) {
  const data = ref<T[]>([]);
  const loading = ref(false);
  const error = ref<string | null>(null);

  // Function to fetch data with optional params
  const fetchData = async (params?: Record<string, string>, options?: RequestInit) => {
    loading.value = true;
    error.value = null;

    try {
      const apiUrl = config[apiName];
      if (!apiUrl) {
        throw new Error(`API URL for ${apiName} not found in configuration.`);
      }

      // Build query string if params are provided
      const queryString = params
        ? "?" + new URLSearchParams(params).toString()
        : "";

      // console.log(`Fetching data from: ${apiUrl}${queryString}`);
      const response = await fetch(`${apiUrl}${queryString}`, {
        method: "GET", // Default method
        headers: {
          "Content-Type": "application/json",
          ...(options?.headers || {}), // Include additional headers if provided
        },
        ...options, // Spread any other options (e.g., method, body)
      });

      if (!response.ok) {
        throw new Error(`Failed to fetch ${apiName}: ${response.statusText}`);
      }

      const responseData = await response.json();
      data.value = responseData;
    } catch (err) {
      error.value = (err as Error).message;
      console.error(`Error fetching ${apiName}:`, err);
    } finally {
      loading.value = false;
    }
  };

  return { data, loading, error, fetchData };
}
