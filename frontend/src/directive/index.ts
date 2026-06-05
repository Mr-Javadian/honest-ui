import type { App } from "vue";

import { hasRole } from "./permission";

// Global registration of directives
export function setupDirective(app: App<Element>) {
  // Make v-hasRole available in all components
  app.directive("hasRole", hasRole);
}
