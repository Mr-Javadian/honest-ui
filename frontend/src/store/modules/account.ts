import { defineStore } from "pinia";

import { getAccountInfoApi, loginApi } from "@/api/account";
import { resetRouter } from "@/router";
import { store } from "@/store";

import { AccountInfo, AccountLoginDto } from "@/api/account/types";

import { useStorage } from "@vueuse/core";

export const useAccountStore = defineStore("account", () => {
  // state
  const token = useStorage("accessToken", "");
  const id = ref(0);
  const username = ref("");
  const roles = ref<Array<string>>([]); // User role codes → route permissions

  /**
   * Login
   *
   * @returns
   */
  function login(accountLoginDto: AccountLoginDto) {
    return new Promise<void>((resolve, reject) => {
      loginApi(accountLoginDto)
        .then((response) => {
          const { tokenType, accessToken } = response.data;
          token.value = tokenType + " " + accessToken; // Bearer eyJhbGciOiJIUzI1NiJ9.xxx.xxx
          resolve();
        })
        .catch((error) => {
          reject(error);
        });
    });
  }

  // Get current account info
  function getAccountInfo() {
    return new Promise<AccountInfo>((resolve, reject) => {
      getAccountInfoApi()
        .then(({ data }) => {
          if (!data) {
            return reject("Verification failed, please Login again.");
          }
          if (!data.roles || data.roles.length <= 0) {
            reject("getAccountInfoApi: roles must be a non-null array!");
          }
          id.value = data.id;
          username.value = data.username;
          roles.value = data.roles;
          resolve(data);
        })
        .catch((error) => {
          reject(error);
        });
    });
  }

  // Logout
  function logout() {
    return new Promise<void>((resolve, reject) => {
      resetRouter();
      resetToken();
      resolve();
    });
  }

  // Reset
  function resetToken() {
    token.value = "";
    id.value = 0;
    username.value = "";
    roles.value = [];
  }

  return {
    token,
    id,
    username,
    roles,
    login,
    getAccountInfo,
    logout,
    resetToken,
  };
});

// Non-setup
export function useAccountStoreHook() {
  return useAccountStore(store);
}
