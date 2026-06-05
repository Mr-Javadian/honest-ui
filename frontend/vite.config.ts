import vue from "@vitejs/plugin-vue";

import { ConfigEnv, defineConfig, loadEnv, UserConfig } from "vite";

import AutoImport from "unplugin-auto-import/vite";
import Components from "unplugin-vue-components/vite";
import { ElementPlusResolver } from "unplugin-vue-components/resolvers";

import Icons from "unplugin-icons/vite";
import IconsResolver from "unplugin-icons/resolver";

import { createSvgIconsPlugin } from "vite-plugin-svg-icons";

import UnoCSS from "unocss/vite";

import path from "path";

const pathSrc = path.resolve(__dirname, "src");

// eslint-disable-next-line no-control-regex
const INVALID_CHAR_REGEX = /[\u0000-\u001F"#$&*+,:;<=>?[\]^`{|}\u007F]/g;
const DRIVE_LETTER_REGEX = /^[a-z]:/i;

import { dynamicBase } from "vite-plugin-dynamic-base";

export default defineConfig(({ mode }: ConfigEnv): UserConfig => {
  const env = loadEnv(mode, process.cwd());
  return {
    base: mode === "production" ? "/__dynamic_base__/" : "/",
    resolve: {
      alias: {
        "@": pathSrc,
      },
    },
    css: {
      // CSS preprocessor
      preprocessorOptions: {
        // Define global SCSS variable
        scss: {
          javascriptEnabled: true,
          additionalData: `
            @use "@/styles/variables.scss" as *;
          `,
        },
      },
    },
    server: {
      host: "0.0.0.0",
      port: Number(env.VITE_APP_PORT),
      open: true, // Auto open browser on dev start
      proxy: {
        // Reverse proxy for CORS
        [env.VITE_APP_BASE_API]: {
          target: "http://127.0.0.1:8081",
          changeOrigin: true,
        },
      },
    },
    plugins: [
      dynamicBase({}),
      vue(),
      UnoCSS({
        /* options */
      }),
      AutoImport({
        // Auto-import Vue functions: ref, reactive, toRef, etc.
        imports: ["vue", "@vueuse/core"],
        eslintrc: {
          enabled: false, // Default `false`
          filepath: "./.eslintrc-auto-import.json", // Default `./.eslintrc-auto-import.json`
          globalsPropValue: true, // Default `true`, (true | false | 'readonly' | 'readable' | 'writable' | 'writeable')
        },
        resolvers: [
          // Auto-import Element Plus functions: ElMessage, ElMessageBox... (with styles)
          ElementPlusResolver(),
          // Auto-import icon components
          IconsResolver({}),
        ],
        vueTemplate: true, // Whether to auto-import in Vue templates
        dts: path.resolve(pathSrc, "types", "auto-imports.d.ts"), // Auto-import types declaration file path, default root; false to disable
      }),

      Components({
        resolvers: [
          // Auto-register icon components
          IconsResolver({
            enabledCollections: ["ep"], // @iconify-json/ep is Element Plus icon library
          }),
          // Auto-import Element Plus components
          ElementPlusResolver(),
        ],
        dts: path.resolve(pathSrc, "types", "components.d.ts"), // Auto-import types declaration file path, default root; false to disable
      }),

      Icons({
        // Auto-install icon libraries
        autoInstall: true,
      }),

      createSvgIconsPlugin({
        // Specify icon folder to cache
        iconDirs: [path.resolve(pathSrc, "assets/icons")],
        // Specify symbolId format
        symbolId: "icon-[dir]-[name]",
      }),
    ],
    build: {
      rollupOptions: {
        output: {
          sanitizeFileName(name: string): string {
            // https://github.com/rollup/rollup/blob/master/src/utils/sanitizeFileName.ts
            const match = DRIVE_LETTER_REGEX.exec(name);
            const driveLetter = match ? match[0] : "";

            // A `:` is only allowed as part of a windows drive letter (ex: C:\foo)
            // Otherwise, avoid them because they can refer to NTFS alternate data streams.
            return (
              driveLetter +
              name.slice(driveLetter.length).replace(INVALID_CHAR_REGEX, "")
            );
          },
        },
      },
    },
  };
});
