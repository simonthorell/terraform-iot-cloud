import { ref } from "vue";
import Dashboard from "~/components/dashboard/dashboard.vue";
import Devices from "~/components/devices/devices.vue";

// List of all components that can be displayed
const componentsMap = {
  Dashboard,
  Devices
};

type ComponentKey = keyof typeof componentsMap;

const currentComponent = ref(componentsMap.Dashboard); // Default to Dashboard

export function useContent() {
  function setContent(component: ComponentKey) {
    currentComponent.value = componentsMap[component];
  }

  return {
    currentComponent,
    setContent,
    componentsMap,
  };
}
