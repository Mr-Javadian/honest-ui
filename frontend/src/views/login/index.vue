<template>
  <div class="login-container">
    <div class="waves">
      <svg class="waves-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 24 150 28" preserveAspectRatio="none">
        <defs>
          <path id="wave-path" d="M-160 44c30 0 58-18 88-18s 58 18 88 18 58-18 88-18 58 18 88 18 v44h-352z" />
        </defs>
        <g class="wave-group">
          <use href="#wave-path" x="48" y="0" class="wave wave-1" />
          <use href="#wave-path" x="48" y="3" class="wave wave-2" />
          <use href="#wave-path" x="48" y="5" class="wave wave-3" />
          <use href="#wave-path" x="48" y="7" class="wave wave-4" />
        </g>
      </svg>
    </div>

    <div class="login-card">
      <div class="card-header">
        <div class="logo-area">
          <svg-icon icon-class="honestui" class="logo-icon" />
        </div>
        <h2 class="panel-title">{{ $t("login.title") }}</h2>
        <div class="headline">
          <span class="headline-word is-visible">Hysteria 2</span>
          <span class="headline-word is-hidden">Management Panel</span>
          <span class="headline-word is-hidden">Secure & Fast</span>
        </div>
      </div>

      <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form">
        <el-form-item prop="username">
          <el-input
            ref="username"
            v-model="loginForm.username"
            :placeholder="$t('login.username')"
            name="username"
            size="large"
            @keyup.enter="handleLogin"
          >
            <template #prefix>
              <svg-icon icon-class="user" class="input-icon" />
            </template>
          </el-input>
        </el-form-item>

        <el-tooltip :disabled="isCapslock === false" content="Caps lock is On" placement="right">
          <el-form-item prop="pass">
            <el-input
              v-model="loginForm.pass"
              :placeholder="$t('login.password')"
              :type="passVisible === false ? 'password' : 'input'"
              size="large"
              name="pass"
              @keyup="checkCapslock"
              @keyup.enter="handleLogin"
            >
              <template #prefix>
                <svg-icon icon-class="password" class="input-icon" />
              </template>
              <template #suffix>
                <span @click="passVisible = !passVisible" class="eye-toggle">
                  <svg-icon :icon-class="passVisible === false ? 'eye' : 'eye-open'" />
                </span>
              </template>
            </el-input>
          </el-form-item>
        </el-tooltip>

        <el-form-item class="login-btn-item">
          <div class="btn-wave-bg">
            <el-button
              size="large"
              :loading="loading"
              type="primary"
              class="login-btn"
              @click.prevent="handleLogin"
            >
              <span v-if="!loading">{{ $t("login.login") }}</span>
            </el-button>
          </div>
        </el-form-item>
      </el-form>

      <div class="card-footer">
        <lang-select class="lang-select" />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
export default {
  name: "Login",
};
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

const loading = ref(false);
const isCapslock = ref(false);
const passVisible = ref(false);
const loginFormRef = ref(ElForm);
let animationTimer: ReturnType<typeof setInterval> | null = null;

const loginForm = ref<AccountLoginDto>({
  username: "",
  pass: "",
});

const loginRules = {
  username: [
    { required: true, message: "Required", trigger: ["change", "blur"] },
    { pattern: /^[a-zA-Z0-9!@#$%^&*()_+-=]{6,32}$/, message: "Username format is incorrect", trigger: ["change", "blur"] },
  ],
  pass: [
    { required: true, message: "Required", trigger: ["change", "blur"] },
    { pattern: /^[a-zA-Z0-9!@#$%^&*()_+-=]{6,32}$/, message: "Password format is incorrect", trigger: ["change", "blur"] },
  ],
};

const checkCapslock = (e: any) => {
  const { key } = e;
  isCapslock.value = key && key.length === 1 && key >= "A" && key <= "Z";
};

const handleLogin = () => {
  loginFormRef.value.validate((valid: boolean) => {
    if (valid) {
      loading.value = true;
      accountStore
        .login({ ...loginForm.value })
        .then(() => {
          const query: LocationQuery = route.query;
          const redirect = (query.redirect as LocationQueryValue) ?? "/";
          const otherQueryParams = Object.keys(query).reduce((acc: any, cur: string) => {
            if (cur !== "redirect") acc[cur] = query[cur];
            return acc;
          }, {});
          router.push({ path: redirect, query: otherQueryParams });
        })
        .catch(() => {})
        .finally(() => { loading.value = false; });
    }
  });
};

const initHeadline = () => {
  const headlines = document.querySelectorAll(".headline-word");
  if (!headlines.length) return;
  let current = 0;
  animationTimer = setInterval(() => {
    headlines.forEach((el, i) => {
      el.classList.remove("is-visible", "is-hidden");
      if (i === current) el.classList.add("is-visible");
      else el.classList.add("is-hidden");
    });
    current = (current + 1) % headlines.length;
  }, 2500);
};

onMounted(() => {
  setTimeout(initHeadline, 1000);
});

onBeforeUnmount(() => {
  if (animationTimer) clearInterval(animationTimer);
});
</script>

<style lang="scss" scoped>
.login-container {
  position: relative;
  width: 100%;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #0a0e1a 0%, #131b2e 40%, #1a1f35 100%);
  overflow: hidden;
}

/* ── SVG Waves ── */
.waves {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 120px;
  z-index: 1;
}

.waves-svg {
  width: 100%;
  height: 100%;
}

.wave-group {
  animation: wave-drift 7s ease-in-out infinite alternate;
}

.wave {
  fill: rgba(99, 102, 241, 0.07);
  animation: wave-move 4s ease-in-out infinite alternate;
}

.wave-2 {
  fill: rgba(99, 102, 241, 0.05);
  animation-duration: 5s;
  animation-delay: -0.5s;
}

.wave-3 {
  fill: rgba(99, 102, 241, 0.03);
  animation-duration: 6s;
  animation-delay: -1s;
}

.wave-4 {
  fill: rgba(99, 102, 241, 0.02);
  animation-duration: 7s;
  animation-delay: -1.5s;
}

@keyframes wave-drift {
  0% { transform: translateX(0); }
  100% { transform: translateX(-20px); }
}

@keyframes wave-move {
  0% { transform: translateY(0); }
  100% { transform: translateY(-8px); }
}

/* ── Login Card ── */
.login-card {
  position: relative;
  z-index: 2;
  width: 420px;
  max-width: 92%;
  background: rgba(22, 28, 50, 0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(99, 102, 241, 0.15);
  border-radius: 16px;
  padding: 40px 36px 32px;
  box-shadow:
    0 0 60px rgba(99, 102, 241, 0.06),
    0 8px 32px rgba(0, 0, 0, 0.4);
  transition: box-shadow 0.3s ease;

  &:hover {
    box-shadow:
      0 0 80px rgba(99, 102, 241, 0.1),
      0 8px 40px rgba(0, 0, 0, 0.5);
  }
}

.card-header {
  text-align: center;
  margin-bottom: 28px;
}

.logo-area {
  display: flex;
  justify-content: center;
  margin-bottom: 12px;
}

.logo-icon {
  width: 52px;
  height: 52px;
}

.panel-title {
  margin: 0 0 8px;
  font-size: 24px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 0.5px;
}

/* ── Animated Headline ── */
.headline {
  position: relative;
  height: 24px;
  overflow: hidden;
}

.headline-word {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 14px;
  font-weight: 400;
  color: rgba(165, 180, 252, 0.7);
  white-space: nowrap;
  opacity: 0;
  transition: all 0.5s ease;
}

.headline-word.is-visible {
  opacity: 1;
  transform: translateX(-50%) translateY(0);
}

.headline-word.is-hidden {
  opacity: 0;
  transform: translateX(-50%) translateY(-12px);
}

/* ── Form ── */
.login-form {
  margin-bottom: 8px;
}

:deep(.el-form-item) {
  margin-bottom: 20px;
  border: none;
  background: transparent;
}

:deep(.el-input__wrapper) {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 10px;
  box-shadow: none;
  padding: 0 12px;
  transition: all 0.25s ease;

  &:hover {
    border-color: rgba(99, 102, 241, 0.35);
    background: rgba(255, 255, 255, 0.06);
  }

  &.is-focus {
    border-color: #6366f1;
    background: rgba(99, 102, 241, 0.08);
    box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.12);
  }
}

:deep(.el-input__inner) {
  color: #e2e8f0;
  background: transparent;
  border: none;
  height: 44px;
  font-size: 14px;
  caret-color: #818cf8;

  &::placeholder {
    color: rgba(148, 163, 184, 0.5);
  }

  &:-webkit-autofill {
    box-shadow: 0 0 0 1000px rgba(22, 28, 50, 0.95) inset !important;
    -webkit-text-fill-color: #e2e8f0 !important;
    border-radius: 8px;
  }

  &:-webkit-autofill:hover,
  &:-webkit-autofill:focus,
  &:-webkit-autofill:active {
    transition: color 99999s ease-out, background-color 99999s ease-out;
    transition-delay: 99999s;
  }
}

.input-icon {
  width: 18px;
  height: 18px;
  color: rgba(148, 163, 184, 0.5);
}

.eye-toggle {
  display: flex;
  align-items: center;
  cursor: pointer;
  color: rgba(148, 163, 184, 0.5);
  transition: color 0.2s;

  &:hover {
    color: rgba(148, 163, 184, 0.8);
  }
}

/* ── Login Button ── */
.login-btn-item {
  margin-top: 8px;
}

.btn-wave-bg {
  position: relative;
  width: 100%;
  height: 46px;
  overflow: hidden;
  border-radius: 10px;
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
  position: relative;
  overflow: hidden;

  &::before {
    content: "";
    position: absolute;
    top: 0;
    left: -100%;
    width: 300%;
    height: 100%;
    background: linear-gradient(
      90deg,
      transparent,
      rgba(255, 255, 255, 0.15),
      transparent
    );
    transition: left 0.6s ease;
  }

  &:hover::before {
    left: 100%;
  }

  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 24px rgba(99, 102, 241, 0.35);
  }

  &:active {
    transform: translateY(0);
  }
}

/* ── Footer ── */
.card-footer {
  display: flex;
  justify-content: center;
  margin-top: 8px;
}

.lang-select {
  :deep(.el-input__wrapper) {
    background: transparent;
    border: none;
    padding: 0;
  }

  :deep(.el-input__inner) {
    color: rgba(148, 163, 184, 0.6);
    font-size: 13px;
  }
}

/* ── Responsive ── */
@media (max-width: 480px) {
  .login-card {
    padding: 28px 20px 24px;
  }

  .panel-title {
    font-size: 20px;
  }

  .waves {
    height: 80px;
  }
}
</style>
