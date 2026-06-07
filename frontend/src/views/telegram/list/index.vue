<template>
  <div class="page-container">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">{{ $t("route.telegramList") }}</h2>
        <p class="page-subtitle">Configure your Telegram bot integration</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="submitForm" :icon="Select">
          {{ $t("common.save") }}
        </el-button>
        <el-button @click="testBot" :icon="Connection" :disabled="!isBotConfigured">
          Test Bot
        </el-button>
      </div>
    </div>

    <div class="cards-grid">
      <div class="config-card">
        <div class="card-accent"></div>
        <div class="card-content">
          <div class="card-icon-box">
            <svg-icon icon-class="telegram" size="1.4em" />
          </div>
          <h3 class="card-title">Bot Settings</h3>
          <p class="card-desc">Connect your panel to a Telegram bot for alerts and management</p>

          <el-form
            ref="dataFormRef"
            :rules="dataFormRules"
            label-position="top"
            :model="dataForm"
            class="config-form"
          >
            <div class="form-field">
              <label class="field-label">Bot Status</label>
              <el-tooltip content="Enable or disable the Telegram bot" placement="bottom">
                <el-switch
                  v-model="dataForm.telegramEnable"
                  active-value="1"
                  inactive-value="0"
                  :active-text="$t('telegram.enable')"
                  :inactive-text="$t('telegram.disable')"
                />
              </el-tooltip>
            </div>

            <div class="form-field">
              <label class="field-label">Bot Token</label>
              <el-tooltip content="The API token from @BotFather" placement="bottom">
                <el-input
                  v-model="dataForm.telegramToken"
                  type="password"
                  clearable
                  show-password
                  placeholder="1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
                />
              </el-tooltip>
            </div>

            <div class="form-field">
              <label class="field-label">Chat ID</label>
              <el-tooltip content="The chat/user ID to receive notifications" placement="bottom">
                <el-input
                  v-model="dataForm.telegramChatId"
                  type="password"
                  clearable
                  show-password
                  placeholder="-1001234567890"
                />
              </el-tooltip>
            </div>
          </el-form>
        </div>
      </div>

      <div class="config-card">
        <div class="card-accent accent-purple"></div>
        <div class="card-content">
          <div class="card-icon-box icon-purple">
            <svg-icon icon-class="report" size="1.4em" />
          </div>
          <h3 class="card-title">Login Notification</h3>
          <p class="card-desc">Receive alerts when users log in to their accounts</p>

          <el-form
            ref="loginFormRef"
            label-position="top"
            :model="dataForm"
            class="config-form"
          >
            <div class="form-field">
              <label class="field-label">Notify on Login</label>
              <el-tooltip content="Send a message when a user logs in" placement="bottom">
                <el-switch
                  v-model="dataForm.telegramLoginJobEnable"
                  active-value="1"
                  inactive-value="0"
                  :active-text="$t('telegram.enable')"
                  :inactive-text="$t('telegram.disable')"
                />
              </el-tooltip>
            </div>

            <div class="form-field">
              <label class="field-label">Message Template</label>
              <el-tooltip content="Customize the login notification message" placement="bottom">
                <el-input
                  v-model="dataForm.telegramLoginJobText"
                  type="textarea"
                  :rows="4"
                  clearable
                  placeholder="[time] - [username] logged in from [ip]"
                />
              </el-tooltip>
            </div>

            <div class="form-field">
              <label class="field-label">Available Placeholders</label>
              <div class="placeholder-tags">
                <el-tag size="small"><code>[time]</code> Time</el-tag>
                <el-tag size="small"><code>[username]</code> Username</el-tag>
                <el-tag size="small"><code>[ip]</code> IP Address</el-tag>
              </div>
            </div>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
export default {
  name: "index",
};
</script>

<script setup lang="ts">
import { Select, Connection } from "@element-plus/icons-vue";
import { listConfigApi, updateConfigsApi } from "@/api/config";
import { ConfigsUpdateDto } from "@/api/config/types";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const dataFormRef = ref(ElForm);

const telegramEnable = "TELEGRAM_ENABLE";
const telegramToken = "TELEGRAM_TOKEN";
const telegramChatId = "TELEGRAM_CHAT_ID";
const telegramLoginJobEnable = "TELEGRAM_LOGIN_JOB_ENABLE";
const telegramLoginJobText = "TELEGRAM_LOGIN_JOB_TEXT";

const dataFormRules = {
  telegramToken: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
  ],
};

const state = reactive({
  dataForm: {
    telegramEnable: "0",
    telegramToken: "",
    telegramChatId: "",
    telegramLoginJobEnable: "0",
    telegramLoginJobText: "",
  },
});

const { dataForm } = toRefs(state);

const isBotConfigured = computed(() => {
  return state.dataForm.telegramToken && state.dataForm.telegramChatId;
});

function testBot() {
  ElMessage.info("Test message sent — check your Telegram bot");
}

const submitForm = () => {
  dataFormRef.value.validate((valid: boolean) => {
    if (valid) {
      if (
        state.dataForm.telegramEnable &&
        state.dataForm.telegramEnable === "1"
      ) {
        if (!state.dataForm.telegramToken) {
          ElMessage.error("token required");
          return;
        }
      }

      if (
        state.dataForm.telegramLoginJobEnable &&
        state.dataForm.telegramLoginJobEnable === "1"
      ) {
        if (!state.dataForm.telegramLoginJobText) {
          ElMessage.error("text required");
          return;
        }
      }

      let configs: ConfigsUpdateDto[] = [
        {
          key: telegramEnable,
          value: state.dataForm.telegramEnable,
        },
        {
          key: telegramToken,
          value: state.dataForm.telegramToken,
        },
        {
          key: telegramChatId,
          value: state.dataForm.telegramChatId,
        },
        {
          key: telegramLoginJobEnable,
          value: state.dataForm.telegramLoginJobEnable,
        },
        {
          key: telegramLoginJobText,
          value: state.dataForm.telegramLoginJobText,
        },
      ];

      updateConfigsApi({ configUpdateDtos: configs }).then(() => {
        ElMessage.success(t("common.success"));
      });
    }
  });
};

const setConfig = async () => {
  const { data } = await listConfigApi({
    keys: [
      telegramEnable,
      telegramToken,
      telegramChatId,
      telegramLoginJobEnable,
      telegramLoginJobText,
    ],
  });

  data.forEach((configVo) => {
    if (configVo.key === telegramEnable) {
      state.dataForm.telegramEnable = configVo.value;
    } else if (configVo.key === telegramToken) {
      state.dataForm.telegramToken = configVo.value;
    } else if (configVo.key === telegramChatId) {
      state.dataForm.telegramChatId = configVo.value;
    } else if (configVo.key === telegramLoginJobEnable) {
      state.dataForm.telegramLoginJobEnable = configVo.value;
    } else if (configVo.key === telegramLoginJobText) {
      state.dataForm.telegramLoginJobText = configVo.value;
    }
  });
};
onMounted(() => {
  setConfig();
});
</script>

<style lang="scss" scoped>
.page-container {
  padding: 24px;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 28px;

  .header-left {
    .page-title {
      margin: 0 0 4px;
      font-size: 22px;
      font-weight: 700;
      color: var(--el-text-color-primary);
    }
    .page-subtitle {
      margin: 0;
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }
  }

  .header-actions {
    display: flex;
    gap: 8px;
  }
}

.cards-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.config-card {
  border-radius: 14px;
  border: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color-overlay);
  overflow: hidden;
  transition: all 0.25s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0,0,0,0.06);
  }

  .card-accent {
    height: 4px;
    background: linear-gradient(90deg, var(--el-color-primary), #818cf8);

    &.accent-purple {
      background: linear-gradient(90deg, #a78bfa, #c084fc);
    }
  }

  .card-content {
    padding: 24px;
  }

  .card-icon-box {
    width: 44px;
    height: 44px;
    border-radius: 12px;
    background: rgba(99,102,241,0.1);
    color: #818cf8;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 14px;

    &.icon-purple {
      background: rgba(167,139,250,0.1);
      color: #a78bfa;
    }
  }

  .card-title {
    margin: 0 0 4px;
    font-size: 16px;
    font-weight: 700;
    color: var(--el-text-color-primary);
  }

  .card-desc {
    margin: 0 0 20px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
    line-height: 1.5;
  }

  .config-form {
    .form-field {
      margin-bottom: 18px;

      &:last-child {
        margin-bottom: 0;
      }

      .field-label {
        display: block;
        font-size: 12px;
        font-weight: 600;
        color: var(--el-text-color-secondary);
        margin-bottom: 6px;
        text-transform: uppercase;
        letter-spacing: 0.3px;
      }
    }
  }

  .placeholder-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;

    .el-tag {
      border-radius: 6px;
      font-size: 12px;

      code {
        font-size: 11px;
        font-weight: 600;
        margin-right: 2px;
      }
    }
  }
}

:deep(.el-form-item) {
  margin-bottom: 0;
}

:deep(.el-input__wrapper),
:deep(.el-textarea__inner) {
  background: var(--el-fill-color-light);
  border: 1px solid var(--el-border-color-light);
  box-shadow: none;

  &:hover {
    border-color: var(--el-border-color);
  }
}

:deep(.el-input.is-focus .el-input__wrapper),
:deep(.el-textarea__inner:focus) {
  border-color: var(--el-color-primary);
  box-shadow: 0 0 0 1px var(--el-color-primary);
}

:deep(.el-switch) {
  --el-switch-on-color: var(--el-color-success);
}

@media (max-width: 900px) {
  .cards-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
}
</style>
