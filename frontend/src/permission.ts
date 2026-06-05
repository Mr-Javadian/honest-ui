import router from "@/router";
import { useAccountStoreHook } from "@/store/modules/account";
import { usePermissionStoreHook } from "@/store/modules/permission";

import NProgress from "nprogress";
import "nprogress/nprogress.css";

NProgress.configure({ showSpinner: false }); // Progress bar

const permissionStore = usePermissionStoreHook();

// Whitelist routes
const whiteList = ["/login", "/register"];

router.beforeEach(async (to, from, next) => {
  NProgress.start();
  const hasToken = localStorage.getItem("accessToken");
  if (hasToken) {
    if (to.path === "/login") {
      // If logged in, go to home
      next({ path: "/" });
      NProgress.done();
    } else {
      const AccountStore = useAccountStoreHook();
      const hasRoles = AccountStore.roles && AccountStore.roles.length > 0;
      if (hasRoles) {
        // No route matched, go to 404
        if (to.matched.length === 0) {
          from.name ? next({ name: from.name }) : next("/404");
        } else {
          next();
        }
      } else {
        try {
          const { roles } = await AccountStore.getAccountInfo();
          const accessRoutes = permissionStore.generateRoutes(roles);
          accessRoutes.forEach((route) => {
            router.addRoute(route);
          });
          next({ ...to, replace: true });
        } catch (error) {
          // Remove token and redirect to login
          await AccountStore.resetToken();
          next(`/login?redirect=${to.path}`);
          NProgress.done();
        }
      }
    }
  } else {
    // Unauthenticated users can access whitelisted pages
    if (whiteList.indexOf(to.path) !== -1) {
      next();
    } else {
      next(`/login?redirect=${to.path}`);
      NProgress.done();
    }
  }
});

router.afterEach(() => {
  NProgress.done();
});
