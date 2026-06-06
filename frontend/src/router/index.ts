import {
  createRouter,
  createWebHashHistory,
  RouteLocationNormalized,
  RouteRecordRaw,
} from "vue-router";

export const Layout = () => import("@/layout/index.vue");

// Static routes
export const constantRoutes: RouteRecordRaw[] = [
  {
    path: "/redirect",
    component: Layout,
    meta: { hidden: true },
    children: [
      {
        path: "/redirect/:path(.*)",
        component: () => import("@/views/redirect/index.vue"),
      },
    ],
  },

  {
    path: "/login",
    component: () => import("@/views/login/index.vue"),
    meta: { hidden: true },
  },
  {
    path: "/",
    component: Layout,
    redirect: "/overview",
    children: [
      {
        path: "401",
        component: () => import("@/views/error-page/401.vue"),
        meta: { hidden: true },
      },
      {
        path: "404",
        component: () => import("@/views/error-page/404.vue"),
        meta: { hidden: true },
      },
    ],
  },
];

export const asyncRoutes: any[] = [
  {
    path: "/overview",
    component: "Layout",
    redirect: { path: "/overview/index" },
    name: "Overview",
    meta: {
      title: "overview",
      icon: "report",
      roles: ["user", "admin"],
    },
    children: [
      {
        path: "index",
        component: "overview/index",
        name: "OverviewIndex",
        meta: {
          title: "overview",
          icon: "report",
          roles: ["user", "admin"],
        },
      },
    ],
  },
  {
    path: "/clients",
    component: "Layout",
    redirect: "/list",
    name: "Clients",
    meta: { title: "clients", icon: "users", roles: ["admin"] },
    children: [
      {
        path: "list",
        component: "account/list/index",
        name: "ClientsList",
        meta: {
          title: "clientsList",
          icon: "users",
          roles: ["admin"],
        },
        props: (route: RouteLocationNormalized) => ({
          focus: route.query.focus,
        }),
      },
    ],
  },
  {
    path: "/telegram",
    component: "Layout",
    redirect: "/list",
    name: "Telegram",
    meta: { title: "telegram", icon: "telegram", roles: ["admin"] },
    children: [
      {
        path: "list",
        component: "telegram/list/index",
        name: "TelegramList",
        meta: {
          title: "telegramList",
          icon: "telegram",
          roles: ["admin"],
        },
      },
    ],
  },
  {
    path: "/hysteria",
    component: "Layout",
    redirect: "/list",
    name: "Hysteria",
    meta: { title: "hysteria", icon: "hysteria", roles: ["admin"] },
    children: [
      {
        path: "list",
        component: "hysteria/list/index",
        name: "HysteriaList",
        meta: {
          title: "hysteriaList",
          icon: "hysteria",
          roles: ["admin"],
        },
      },
    ],
  },
  {
    path: "/config",
    component: "Layout",
    redirect: "/list",
    name: "Config",
    meta: { title: "config", icon: "setting", roles: ["admin"] },
    children: [
      {
        path: "list",
        component: "config/list/index",
        name: "ConfigList",
        meta: {
          title: "configList",
          icon: "setting",
          roles: ["admin"],
        },
        props: (route: RouteLocationNormalized) => ({
          focus: route.query.focus,
        }),
      },
    ],
  },
  {
    path: "/log",
    component: "Layout",
    redirect: "/system",
    name: "Log",
    meta: { title: "log", icon: "error", roles: ["admin"] },
    children: [
      {
        path: "system",
        component: "log/system/index",
        name: "LogSystem",
        meta: {
          title: "logSystem",
          icon: "log-system",
          roles: ["admin"],
        },
      },
      {
        path: "hysteria",
        component: "log/hysteria/index",
        name: "LogHysteria",
        meta: {
          title: "logHysteria",
          icon: "log-hysteria",
          roles: ["admin"],
        },
      },
    ],
  },
];

/**
 * Create router
 */
const router = createRouter({
  history: createWebHashHistory(),
  routes: constantRoutes as RouteRecordRaw[],
  // Restore scroll position on refresh
  scrollBehavior: () => ({ left: 0, top: 0 }),
});

/**
 * Reset router
 */
export function resetRouter() {
  router.replace({ path: "/login" });
  location.reload();
}

export default router;
