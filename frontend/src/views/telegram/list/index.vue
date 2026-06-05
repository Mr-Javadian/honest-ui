<template>
  <div class="page-container">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">{{ $t("route.telegramList") }}</h2>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="submitForm" :icon="Select">
          {{ $t("common.save") }}
        </el-button>
      </div>
    </div>

    <el-card shadow="never" class="content-card">
      <el-form
        ref="dataFormRef"
        :rules="dataFormRules"
        label-position="top"
        :model="dataForm"
      >
        <div class="form-section">
          <h3 class="section-title">Bot Settings</h3>
          <div class="form-row">
            <el-form-item :label="$t('telegram.enable')" prop="telegramEnable">
              <el-tooltip :content="$t('telegram.telegramEnable')" placement="bottom">
                <el-switch
                  v-model="dataForm.telegramEnable"
                  active-value="1"
                  inactive-value="0"
                  :active-text="$t('telegram.enable')"
                  :inactive-text="$t('telegram.disable')"
                />
              </el-tooltip>
            </el-form-item>
          </div>
          <div class="form-row">
            <el-form-item
              :label="$t('telegram.telegramToken')"
              prop="telegramToken"
            >
              <el-tooltip :content="$t('telegram.telegramToken')" placement="bottom">
                <el-input
                  v-model="dataForm.telegramToken"
                  type="password"
                  clearable
                  show-password
                />
              </el-tooltip>
            </el-form-item>
            <el-form-item
              :label="$t('telegram.telegramChatId')"
              prop="telegramChatId"
            >
              <el-tooltip :content="$t('telegram.telegramChatId')" placement="bottom">
                <el-input
                  v-model="dataForm.telegramChatId"
                  type="password"
                  clearable
                  show-password
                />
              </el-tooltip>
            </el-form-item>
          </div>
        </div>

        <el-divider />

        <div class="form-section">
          <h3 class="section-title">{{ $t("telegram.telegramJob") }}</h3>
          <div class="form-row">
            <el-form-item :label="$t('telegram.telegramLoginJobEnable')" prop="telegramLoginJobEnable">
              <el-tooltip :content="$t('telegram.telegramLoginJobEnable')" placement="bottom">
                <el-switch
                  v-model="dataForm.telegramLoginJobEnable"
                  active-value="1"
                  inactive-value="0"
                  :active-text="$t('telegram.enable')"
                  :inactive-text="$t('telegram.disable')"
                />
              </el-tooltip>
            </el-form-item>
          </div>
          <div class="form-row">
            <el-form-item
              :label="$t('telegram.telegramLoginJobText')"
              prop="telegramLoginJobText"
            >
              <el-tooltip :content="$t('telegram.telegramLoginJobText')" placement="bottom">
                <el-input
                  v-model="dataForm.telegramLoginJobText"
                  type="textarea"
                  :rows="4"
                  clearable
                />
              </el-tooltip>
            </el-form-item>
          </div>
          <div class="form-row">
            <el-form-item>
              <el-tooltip :content="$t('telegram.placeholder')" placement="bottom">
                <el-alert type="info" :closable="false" class="placeholder-alert">
                  <template #title>
                    <span class="placeholder-title">{{ $t('telegram.placeholder') }}</span>
                  </template>
                  <p><code>[time]</code> - Time</p>
                  <p><code>[username]</code> - Username</p>
                  <p><code>[ip]</code> - IP Address</p>
                </el-alert>
              </el-tooltip>
            </el-form-item>
          </div>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script lang="ts">
export default {
  name: "index",
};
</script>

<script setup lang="ts">
import { Select } from "@element-plus/icons-vue";
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
  margin-bottom: 24px;

  .header-left {
    .page-title {
      margin: 0 0 4px;
      font-size: 20px;
      font-weight: 600;
      color: var(--text-primary, #1a1a2e);
    }
    .page-subtitle {
      font-size: 13px;
      color: var(--text-secondary, #8b8fa3);
    }
  }

  .header-actions {
    display: flex;
    gap: 8px;
  }
}

.content-card {
  border-radius: 8px;
  border: 1px solid var(--border-color, #e8e8ef);

  :deep(.el-card__body) {
    padding: 32px;
  }
}

.form-section {
  .section-title {
    margin: 0 0 20px;
    font-size: 15px;
    font-weight: 600;
    color: var(--text-primary, #1a1a2e);
    padding-left: 12px;
    border-left: 3px solid var(--el-color-primary, #5b6abf);
  }
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0 24px;

  .el-form-item {
    margin-bottom: 18px;
  }
}

.el-divider {
  margin: 24px 0;
  border-color: var(--border-color, #e8e8ef);
}

.placeholder-alert {
  width: 100%;

  p {
    margin: 4px 0;
    font-size: 13px;
    color: var(--text-secondary, #606266);

    code {
      background: var(--bg-code, #f5f7fa);
      padding: 1px 6px;
      border-radius: 3px;
      font-size: 12px;
      color: var(--el-color-primary, #5b6abf);
    }
  }
}

.el-form-item:last-child {
  margin-bottom: 0;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .form-row {
    grid-template-columns: 1fr;
  }
}
</style>
