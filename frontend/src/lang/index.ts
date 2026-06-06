import { createI18n } from "vue-i18n";
import { useAppStore } from "@/store/modules/app";

const appStore = useAppStore();
// Language packs
import enLocale from "./package/en";
import ruLocale from "./package/ru";
import zhCnLocale from "./package/zh-cn";
import faLocale from "./package/fa";

const messages = {
  en: {
    ...enLocale,
  },
  ru: {
    ...ruLocale,
  },
  "zh-cn": {
    ...zhCnLocale,
  },
  fa: {
    ...faLocale,
  },
};

const i18n = createI18n({
  legacy: false,
  locale: appStore.language,
  messages: messages,
  globalInjection: true,
});

export default i18n;
