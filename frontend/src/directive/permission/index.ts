import { useAccountStoreHook } from "@/store/modules/account";
import { Directive, DirectiveBinding } from "vue";

/**
 * Role permission
 */
export const hasRole: Directive = {
  mounted(el: HTMLElement, binding: DirectiveBinding) {
    const { value } = binding;

    if (value) {
      const requiredRoles = value; // Role codes required by DOM binding
      const { roles } = useAccountStoreHook();
      const hasRole = roles.some((perm) => {
        return requiredRoles.includes(perm);
      });

      if (!hasRole) {
        el.parentNode && el.parentNode.removeChild(el);
      }
    } else {
      throw new Error("need roles! Like v-has-role=\"['admin', 'user']\"");
    }
  },
};
