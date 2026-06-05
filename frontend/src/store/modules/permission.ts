import { RouteRecordRaw } from "vue-router";
import { defineStore } from "pinia";
import { asyncRoutes, constantRoutes } from "@/router";
import { store } from "@/store";

const modules = import.meta.glob("../../views/**/**.vue");
const Layout = () => import("@/layout/index.vue");

/**
 * Use meta.role to determine if the current user has permission
 *
 * @param roles User role collection
 * @param route Route
 * @returns
 */
const hasPermission = (roles: string[], route: RouteRecordRaw) => {
  if (route.meta && route.meta.roles) {
    // Admin role has all permissions, skip validation
    if (roles.includes("admin")) {
      return true;
    }
    return roles.some((role) => {
      if (route.meta?.roles !== undefined) {
        return (route.meta.roles as string[]).includes(role);
      }
    });
  }
  return false;
};

/**
 * Recursively filter authorized async (dynamic) routes
 *
 * @param routes Async (dynamic) routes from API
 * @param roles User role collection
 * @returns Returns authorized async (dynamic) routes for the user
 */
const filterAsyncRoutes = (routes: RouteRecordRaw[], roles: string[]) => {
  const asyncRoutes: RouteRecordRaw[] = [];

  routes.forEach((route) => {
    const tmpRoute = { ...route }; // ES6 spread operator copies new object

    // Check if the user (role) has access to the route
    if (hasPermission(roles, tmpRoute)) {
      if (tmpRoute.component?.toString() == "Layout") {
        tmpRoute.component = Layout;
      } else {
        const component = modules[`../../views/${tmpRoute.component}.vue`];
        if (component) {
          tmpRoute.component = component;
        } else {
          tmpRoute.component = modules[`../../views/error-page/404.vue`];
        }
      }

      if (tmpRoute.children) {
        tmpRoute.children = filterAsyncRoutes(tmpRoute.children, roles);
      }

      asyncRoutes.push(tmpRoute);
    }
  });

  return asyncRoutes;
};

// setup
export const usePermissionStore = defineStore("permission", () => {
  // state
  const routes = ref<RouteRecordRaw[]>([]);

  // actions
  function setRoutes(newRoutes: RouteRecordRaw[]) {
    routes.value = constantRoutes.concat(newRoutes);
  }

  /**
   * Generate dynamic routes
   *
   * @param roles User role collection
   * @returns
   */
  function generateRoutes(roles: string[]) {
    // Get accessible routes based on role
    const accessedRoutes = filterAsyncRoutes(asyncRoutes, roles);
    setRoutes(accessedRoutes);
    return accessedRoutes;
  }

  return { routes, setRoutes, generateRoutes };
});

// Non-setup
export function usePermissionStoreHook() {
  return usePermissionStore(store);
}
