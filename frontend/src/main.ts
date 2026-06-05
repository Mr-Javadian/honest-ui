import { createApp } from "vue";
import App from "./App.vue";
import router from "@/router";
import { setupStore } from "@/store";
import { setupDirective } from "@/directive";

import "@/permission";

// Local SVG icons
import "virtual:svg-icons-register";

// i18n
import i18n from "@/lang/index";

// Styles
import "element-plus/theme-chalk/dark/css-vars.css";
import "@/styles/index.scss";
import "uno.css";

const app = createApp(App);
// Register custom directives
setupDirective(app);
// Register state management store
setupStore(app);

app.use(router).use(i18n).mount("#app");
