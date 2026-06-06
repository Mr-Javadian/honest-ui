<template>
  <div class="login-page" :class="[isDark ? 'is-dark' : 'is-light']">
    <div class="login-bg">
      <div class="bg-blob blob-1"></div>
      <div class="bg-blob blob-2"></div>
      <div class="bg-grid"></div>
    </div>

    <div class="login-card">
      <div class="login-card-inner">
        <div class="login-header">
          <div class="login-logo">
            <svg-icon icon-class="honestui" size="2.4em" />
          </div>
          <h2 class="login-title">{{ $t("login.title") }}</h2>
          <div class="login-headline">
            <span v-for="(word, i) in headlineWords" :key="i" class="headline-word" :class="headlineClass(i)">{{ word }}</span>
          </div>
          <span class="login-version">v{{ appVersion }}</span>
        </div>

        <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form">
          <el-form-item prop="username">
            <el-input ref="username" v-model="loginForm.username" :placeholder="$t('login.username')" name="username" size="large" @keyup.enter="handleLogin">
              <template #prefix><svg-icon icon-class="user" class="input-icon" /></template>
            </el-input>
          </el-form-item>

          <el-tooltip :disabled="!isCapslock" content="Caps lock is On" placement="right">
            <el-form-item prop="pass">
              <el-input v-model="loginForm.pass" :placeholder="$t('login.password')" :type="passVisible ? 'input' : 'password'" size="large" name="pass" @keyup="checkCapslock" @keyup.enter="handleLogin">
                <template #prefix><svg-icon icon-class="password" class="input-icon" /></template>
                <template #suffix>
                  <span class="eye-toggle" @click="passVisible = !passVisible">
                    <svg-icon :icon-class="passVisible ? 'eye-open' : 'eye'" />
                  </span>
                </template>
              </el-input>
            </el-form-item>
          </el-tooltip>

          <el-form-item prop="captcha">
            <div class="captcha-row">
              <div class="captcha-code">
                <span v-for="(d, i) in captchaDigits" :key="i" class="captcha-digit" :style="captchaStyle(i)">{{ d }}</span>
                <button class="captcha-refresh" type="button" @click="refreshCaptcha" title="Refresh"><svg-icon icon-class="refresh" class="refresh-icon" /></button>
              </div>
              <el-input v-model="loginForm.captcha" placeholder="Captcha" size="large" maxlength="4" class="captcha-input" @keyup.enter="handleLogin">
                <template #prefix><svg-icon icon-class="report" class="input-icon" /></template>
              </el-input>
            </div>
          </el-form-item>

          <el-form-item>
            <el-button size="large" :loading="loading" type="primary" class="login-btn" @click.prevent="handleLogin">
              <span v-if="!loading">{{ $t("login.login") }}</span>
            </el-button>
          </el-form-item>
        </el-form>

        <div class="login-footer">
          <button class="theme-toggle" @click="toggleTheme" :title="isDark ? 'Light mode' : 'Dark mode'">
            <svg-icon :icon-class="isDark ? 'sunny' : 'moon'" size="1.2em" />
          </button>
          <lang-select class="login-lang" />
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
export default { name: "Login" }
</script>

<script setup lang="ts">
import { onMounted, onBeforeUnmount } from "vue";
import router from "@/router";
import LangSelect from "@/components/LangSelect/index.vue";
import SvgIcon from "@/components/SvgIcon/index.vue";
import { useAccountStore } from "@/store/modules/account";
import { LocationQuery, LocationQueryValue, useRoute } from "vue-router";
import { AccountLoginDto } from "@/api/account/types";

const accountStore = useAccountStore();
const route = useRoute();

const appVersion = "0.4.6";
const loading = ref(false);
const isCapslock = ref(false);
const passVisible = ref(false);
const captchaValue = ref("");
const captchaDigits = ref<string[]>([]);
const loginFormRef = ref(ElForm);
let animationTimer: ReturnType<typeof setInterval> | null = null;
let headlineCurrent = 0;

const isDark = useDark();
const toggleDark = useToggle(isDark);
const toggleTheme = () => toggleDark();

const headlineWords = ["Hysteria 2", "Management Panel", "Secure & Fast"];

const headlineClass = (i: number) => ({
  "is-visible": i === headlineCurrent,
  "is-hidden": i !== headlineCurrent,
});

interface LoginForm extends AccountLoginDto {
  captcha: string;
}

const loginForm = ref<LoginForm>({ username: "", pass: "", captcha: "" });

const captchaStyle = (i: number) => ({
  transform: `rotate(${(i - 1.5) * 8}deg) translateY(${i % 2 === 0 ? -2 : 2}px)`,
  color: ["#818cf8", "#a78bfa", "#6366f1", "#7c3aed"][i],
  fontSize: `${22 + (i % 2) * 4}px`,
});

const generateCaptcha = () => {
  const code = Math.floor(1000 + Math.random() * 9000).toString();
  captchaDigits.value = code.split("");
  captchaValue.value = code;
  loginForm.value.captcha = "";
};

const refreshCaptcha = () => generateCaptcha();

const loginRules = {
  username: [{ required: true, message: "Required", trigger: ["change", "blur"] }, { pattern: /^[a-zA-Z0-9!@#$%^&*()_+=-]{6,32}$/, message: "Username format is incorrect", trigger: ["change", "blur"] }],
  pass: [{ required: true, message: "Required", trigger: ["change", "blur"] }, { pattern: /^[a-zA-Z0-9!@#$%^&*()_+=-]{6,32}$/, message: "Password format is incorrect", trigger: ["change", "blur"] }],
  captcha: [{ required: true, message: "Enter captcha", trigger: ["change", "blur"] }, { pattern: /^\d{4}$/, message: "4 digits required", trigger: ["change", "blur"] }],
};

const checkCapslock = (e: any) => {
  const { key } = e;
  isCapslock.value = key && key.length === 1 && key >= "A" && key <= "Z";
};

const handleLogin = () => {
  loginFormRef.value.validate((valid: boolean) => {
    if (!valid) return;
    if (loginForm.value.captcha !== captchaValue.value) {
      ElMessage.warning("Captcha does not match");
      refreshCaptcha();
      return;
    }
    loading.value = true;
    const { captcha: _, ...creds } = loginForm.value;
    accountStore.login(creds).then(() => {
      const query: LocationQuery = route.query;
      const redirect = (query.redirect as LocationQueryValue) ?? "/";
      const otherQueryParams = Object.keys(query).reduce((acc: any, cur: string) => {
        if (cur !== "redirect") acc[cur] = query[cur];
        return acc;
      }, {});
      router.push({ path: redirect, query: otherQueryParams });
    }).catch(() => refreshCaptcha()).finally(() => { loading.value = false; });
  });
};

const advanceHeadline = () => {
  headlineCurrent = (headlineCurrent + 1) % headlineWords.length;
};

onMounted(() => {
  generateCaptcha();
  animationTimer = setInterval(advanceHeadline, 2500);
});

onBeforeUnmount(() => {
  if (animationTimer) clearInterval(animationTimer);
});
</script>

<style lang="scss" scoped>
.login-page {
  position: relative;
  width: 100%;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  transition: background 0.4s ease;

  &.is-dark {
    background: linear-gradient(135deg, #0a0e1a 0%, #131b2e 40%, #1a1f35 100%);
    --card-bg: rgba(22, 28, 50, 0.75);
    --card-border: rgba(99, 102, 241, 0.12);
    --input-bg: rgba(255, 255, 255, 0.04);
    --input-border: rgba(255, 255, 255, 0.08);
    --input-hover-border: rgba(99, 102, 241, 0.35);
    --input-focus-bg: rgba(99, 102, 241, 0.08);
    --input-color: #e2e8f0;
    --input-placeholder: rgba(148, 163, 184, 0.5);
    --title-color: #fff;
    --text-secondary: rgba(165, 180, 252, 0.7);
    --version-color: rgba(148, 163, 184, 0.45);
    --icon-color: rgba(148, 163, 184, 0.5);
    --blob-1: rgba(99, 102, 241, 0.08);
    --blob-2: rgba(139, 92, 246, 0.06);
    --grid-color: rgba(99, 102, 241, 0.04);
  }

  &.is-light {
    background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 40%, #c7d2fe 100%);
    --card-bg: rgba(255, 255, 255, 0.75);
    --card-border: rgba(99, 102, 241, 0.15);
    --input-bg: rgba(255, 255, 255, 0.7);
    --input-border: rgba(0, 0, 0, 0.08);
    --input-hover-border: rgba(99, 102, 241, 0.4);
    --input-focus-bg: rgba(99, 102, 241, 0.05);
    --input-color: #1e293b;
    --input-placeholder: rgba(100, 116, 139, 0.5);
    --title-color: #1e293b;
    --text-secondary: rgba(100, 116, 139, 0.8);
    --version-color: rgba(100, 116, 139, 0.45);
    --icon-color: rgba(100, 116, 139, 0.5);
    --blob-1: rgba(99, 102, 241, 0.06);
    --blob-2: rgba(139, 92, 246, 0.04);
    --grid-color: rgba(99, 102, 241, 0.06);
  }
}

.login-bg {
  position: absolute;
  inset: 0;
  z-index: 1;
  overflow: hidden;
}

.bg-blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  animation: blob-float 20s ease-in-out infinite alternate;
}

.blob-1 {
  width: 500px;
  height: 500px;
  top: -150px;
  right: -100px;
  background: var(--blob-1);
}

.blob-2 {
  width: 400px;
  height: 400px;
  bottom: -100px;
  left: -100px;
  background: var(--blob-2);
  animation-delay: -10s;
}

.bg-grid {
  position: absolute;
  inset: 0;
  background-image: linear-gradient(var(--grid-color) 1px, transparent 1px), linear-gradient(90deg, var(--grid-color) 1px, transparent 1px);
  background-size: 64px 64px;
  mask-image: radial-gradient(ellipse 80% 60% at 50% 50%, black 30%, transparent 70%);
  -webkit-mask-image: radial-gradient(ellipse 80% 60% at 50% 50%, black 30%, transparent 70%);
}

@keyframes blob-float {
  0% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(30px, -30px) scale(1.05); }
  66% { transform: translate(-20px, 20px) scale(0.95); }
  100% { transform: translate(20px, -10px) scale(1.02); }
}

.login-card {
  position: relative;
  z-index: 2;
  width: 400px;
  max-width: 92%;
}

.login-card-inner {
  background: var(--card-bg);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid var(--card-border);
  border-radius: 20px;
  padding: 36px 32px 28px;
  box-shadow: 0 8px 40px rgba(0, 0, 0, 0.2);
  transition: all 0.4s ease;
}

.login-header {
  text-align: center;
  margin-bottom: 28px;
}

.login-logo {
  display: flex;
  justify-content: center;
  margin-bottom: 4px;
  color: #818cf8;
  filter: drop-shadow(0 0 12px rgba(99, 102, 241, 0.3));
}

.login-title {
  margin: 12px 0 6px;
  font-size: 24px;
  font-weight: 700;
  color: var(--title-color);
  letter-spacing: 0.5px;
}

.login-version {
  display: inline-block;
  margin-top: 6px;
  font-size: 11px;
  font-weight: 500;
  color: var(--version-color);
  letter-spacing: 0.3px;
}

.login-headline {
  position: relative;
  height: 20px;
  overflow: hidden;
}

.headline-word {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 13px;
  font-weight: 400;
  color: var(--text-secondary);
  white-space: nowrap;
  opacity: 0;
  transition: all 0.5s ease;
  &.is-visible { opacity: 1; transform: translateX(-50%) translateY(0); }
  &.is-hidden { opacity: 0; transform: translateX(-50%) translateY(-12px); }
}

.login-form { margin-bottom: 4px; }

:deep(.el-form-item) {
  margin-bottom: 18px;
  border: none;
  background: transparent;
}

:deep(.el-input__wrapper) {
  background: var(--input-bg);
  border: 1px solid var(--input-border);
  border-radius: 10px;
  box-shadow: none;
  padding: 0 12px;
  transition: all 0.25s ease;
  &:hover { border-color: var(--input-hover-border); background: var(--input-bg); }
  &.is-focus { border-color: #6366f1; background: var(--input-focus-bg); box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.12); }
}

:deep(.el-input__inner) {
  color: var(--input-color);
  background: transparent;
  border: none;
  height: 44px;
  font-size: 14px;
  caret-color: #818cf8;
  &::placeholder { color: var(--input-placeholder); }
  &:-webkit-autofill {
    box-shadow: 0 0 0 1000px rgba(22, 28, 50, 0.95) inset !important;
    -webkit-text-fill-color: var(--input-color) !important;
    border-radius: 8px;
  }
}

.input-icon { width: 18px; height: 18px; color: var(--icon-color); }

.eye-toggle {
  display: flex; align-items: center; cursor: pointer;
  color: var(--icon-color); transition: color 0.2s;
  &:hover { color: var(--text-secondary); }
}

.captcha-row {
  display: flex; align-items: center; gap: 10px; width: 100%;
}

.captcha-code {
  display: flex; align-items: center; gap: 3px;
  padding: 0 14px; height: 44px;
  background: rgba(99, 102, 241, 0.08);
  border: 1px solid rgba(99, 102, 241, 0.15);
  border-radius: 10px;
  user-select: none; flex-shrink: 0;
}

.captcha-digit {
  font-family: "Courier New", monospace;
  font-weight: 700;
  transition: all 0.2s ease;
}

.captcha-refresh {
  display: flex; align-items: center; justify-content: center;
  margin-left: 6px; padding: 0; border: none;
  background: transparent; cursor: pointer;
  color: rgba(148, 163, 184, 0.4);
  transition: color 0.2s;
  &:hover { color: rgba(99, 102, 241, 0.7); }
}

.refresh-icon { width: 16px; height: 16px; }

.captcha-input {
  flex: 1; min-width: 0;
  :deep(.el-input__wrapper) { padding: 0 10px; }
  :deep(.el-input__inner) { text-align: center; font-family: "Courier New", monospace; font-size: 18px; letter-spacing: 4px; }
}

.login-btn {
  width: 100%;
  height: 46px !important;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 1px;
  border: none;
  border-radius: 10px;
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
  transition: all 0.3s ease;
  &:hover { transform: translateY(-1px); box-shadow: 0 6px 24px rgba(99, 102, 241, 0.35); }
  &:active { transform: translateY(0); }
}

.login-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 12px;
}

.theme-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: none;
  background: transparent;
  cursor: pointer;
  color: var(--icon-color);
  transition: all 0.2s ease;
  &:hover {
    background: var(--input-bg);
    color: var(--text-secondary);
  }
}

.login-lang {
  :deep(.el-input__wrapper) { background: transparent; border: none; padding: 0; }
  :deep(.el-input__inner) { color: var(--icon-color); font-size: 13px; }
}

@media (max-width: 480px) {
  .login-card-inner { padding: 24px 20px 20px; }
  .login-title { font-size: 20px; }
  .login-logo { font-size: 2em; }
}
</style>
