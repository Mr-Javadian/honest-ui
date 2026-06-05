<template>
  <div class="page-container">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">{{ $t("route.configList") }}</h2>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="submitForm" :icon="Select">
          {{ $t("common.save") }}
        </el-button>
        <el-button @click="handleRestartServer">
          <template #icon><i-ep-refreshRight /></template>
          {{ $t("config.restartServer") }}
        </el-button>
        <el-upload
          v-model:file-list="fileList"
          :http-request="handleImport"
          :show-file-list="false"
          accept=".json"
          :limit="1"
          :before-upload="beforeImport"
        >
          <el-button>
            <template #icon><i-ep-upload /></template>
            {{ $t("common.import") }}
          </el-button>
        </el-upload>
        <el-button @click="handleExport">
          <template #icon><i-ep-download /></template>
          {{ $t("common.export") }}
        </el-button>
      </div>
    </div>

    <el-card shadow="never" class="content-card">
      <el-form
        ref="dataFormRef"
        :rules="dataFormRules"
        :model="dataForm"
        label-position="top"
      >
        <div class="form-section">
          <h3 class="section-title">Web Settings</h3>
          <div class="form-row">
            <el-form-item :label="$t('config.huiWebPort')" prop="huiWebPort">
              <el-input
                v-model="dataForm.huiWebPort"
                :placeholder="$t('config.huiWebPort')"
                clearable
              />
            </el-form-item>
            <el-form-item :label="$t('config.huiWebContext')" prop="huiWebContext">
              <el-input
                v-model="dataForm.huiWebContext"
                :placeholder="$t('config.huiWebContext')"
                clearable
              />
            </el-form-item>
          </div>
        </div>

        <el-divider />

        <div class="form-section">
          <h3 class="section-title">Hysteria2 Settings</h3>
          <div class="form-row">
            <el-form-item
              :label="$t('config.hysteria2TrafficTime')"
              prop="hysteria2TrafficTime"
            >
              <el-input
                v-model="dataForm.hysteria2TrafficTime"
                :placeholder="$t('config.hysteria2TrafficTime')"
                clearable
              />
            </el-form-item>
            <el-form-item
              :label="$t('config.resetTrafficCron')"
              prop="resetTrafficCron"
            >
              <el-tooltip
                :content="$t('config.resetTrafficCronTip')"
                placement="bottom"
              >
                <el-select
                  v-model="dataForm.resetTrafficCron"
                  filterable
                  allow-create
                  clearable
                  :placeholder="$t('config.resetTrafficCron')"
                >
                  <el-option
                    v-for="item in cronResetTraffic"
                    :key="item.value"
                    :label="item.key"
                    :value="item.value"
                  />
                </el-select>
              </el-tooltip>
            </el-form-item>
          </div>
        </div>

        <el-divider />

        <div class="form-section">
          <h3 class="section-title">HTTPS Settings</h3>
          <div class="form-row">
            <el-form-item :label="$t('config.huiHttps')" prop="huiHttps">
              <div class="https-toggle">
                <el-select v-model="huiHttps" ref="huiHttpsRef">
                  <el-option
                    v-for="item in huiHttpsList"
                    :key="item.key"
                    :label="item.key"
                    :value="item.value"
                  />
                </el-select>
                <el-button v-if="huiHttps" @click="setCertPath" class="ml-2">
                  {{ t("config.useHysteria2Cert") }}
                </el-button>
              </div>
            </el-form-item>
          </div>
          <div v-if="huiHttps" class="form-row">
            <el-form-item
              :label="$t('config.huiCrtPath')"
              prop="huiCrtPath"
            >
              <el-input
                v-model="dataForm.huiCrtPath"
                :placeholder="$t('config.huiCrtPath')"
                clearable
              />
              <el-upload
                ref="uploadCrtFile"
                action=""
                :file-list="crtFileList"
                :http-request="uploadCertFile"
                accept=".crt"
                :before-upload="() => { crtFileList = []; }"
                :show-file-list="false"
                :limit="1"
              >
                <template #trigger>
                  <el-button class="ml-2">{{ t("config.uploadCrtFile") }}</el-button>
                </template>
              </el-upload>
            </el-form-item>
            <el-form-item
              :label="$t('config.huiKeyPath')"
              prop="huiKeyPath"
            >
              <el-input
                v-model="dataForm.huiKeyPath"
                :placeholder="$t('config.huiKeyPath')"
                clearable
              />
              <el-upload
                ref="uploadKeyFile"
                action=""
                :file-list="keyFileList"
                :http-request="uploadCertFile"
                accept=".key"
                :before-upload="() => { keyFileList = []; }"
                :show-file-list="false"
                :limit="1"
              >
                <template #trigger>
                  <el-button class="ml-2">{{ t("config.uploadKeyFile") }}</el-button>
                </template>
              </el-upload>
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
import {
  exportConfigApi,
  hysteria2AcmePathApi,
  importConfigApi,
  listConfigApi,
  restartServerApi,
  updateConfigsApi,
  uploadCertFileApi,
} from "@/api/config";
import { ConfigsUpdateDto } from "@/api/config/types";
import {
  UploadFile,
  UploadRawFile,
  UploadRequestOptions,
} from "element-plus/lib/components";
import { useI18n } from "vue-i18n";
import { useRoute } from "vue-router";
import { UploadUserFile } from "element-plus";

const { t } = useI18n();
const route = useRoute();

const dataFormRef = ref(ElForm);
const huiHttpsRef = ref(ElSelect);

const huiWebPortKey = "H_UI_WEB_PORT";
const huiWebContext = "H_UI_WEB_CONTEXT";
const hysteria2TrafficTimeKey = "HYSTERIA2_TRAFFIC_TIME";
const huiCrtPathKey = "H_UI_CRT_PATH";
const huiKeyPathKey = "H_UI_KEY_PATH";
const resetTrafficCronKey = "RESET_TRAFFIC_CRON";

const huiHttpsList = [
  { key: t("common.yes"), value: 1 },
  { key: t("common.no"), value: 0 },
];

const cronResetTraffic = [
  { key: t("config.resetTrafficMonth"), value: "@monthly" },
  { key: t("config.resetTrafficWeek"), value: "@weekly" },
];

const dataFormRules = {
  huiWebPort: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
    {
      pattern: /^\d+$/,
      message: "field must be a integer",
      trigger: ["change", "blur"],
    },
  ],
  huiWebContext: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
    {
      pattern: /^\/([a-z0-9]+(\/[a-z0-9]+)*)?$/,
      message: "field must start with / and contain only lowercase letters (a-z) and numbers (0-9)",
      trigger: ["change", "blur"],
    },
  ],
  hysteria2TrafficTime: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
    {
      pattern: /^\d+(\.\d)?$/,
      message: "field must be a number with up to one decimal place",
      trigger: ["change", "blur"],
    },
  ],
};

const state = reactive({
  dataForm: {
    huiWebPort: "8081",
    huiWebContext: "/",
    hysteria2TrafficTime: "1",
    huiCrtPath: "",
    huiKeyPath: "",
    resetTrafficCron: "",
  },
  huiHttps: 0,
  fileList: [] as UploadUserFile[],
  crtFileList: [] as UploadUserFile[],
  keyFileList: [] as UploadUserFile[],
});

const { dataForm, huiHttps, fileList, crtFileList, keyFileList } =
  toRefs(state);

const submitForm = () => {
  dataFormRef.value.validate((valid: boolean) => {
    if (valid) {
      if (state.huiHttps) {
        if (!state.dataForm.huiCrtPath || !state.dataForm.huiKeyPath) {
          ElMessage.error("crt and key required");
          return;
        }
      }

      if (!state.huiHttps) {
        state.dataForm.huiCrtPath = "";
        state.dataForm.huiKeyPath = "";
      }

      let configs: ConfigsUpdateDto[] = [
        {
          key: huiWebPortKey,
          value: state.dataForm.huiWebPort,
        },
        {
          key: huiWebContext,
          value: state.dataForm.huiWebContext,
        },
        {
          key: hysteria2TrafficTimeKey,
          value: state.dataForm.hysteria2TrafficTime,
        },
        {
          key: huiCrtPathKey,
          value: state.dataForm.huiCrtPath,
        },
        {
          key: huiKeyPathKey,
          value: state.dataForm.huiKeyPath,
        },
        {
          key: resetTrafficCronKey,
          value: state.dataForm.resetTrafficCron,
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
      huiCrtPathKey,
      huiWebContext,
      huiKeyPathKey,
      huiWebPortKey,
      hysteria2TrafficTimeKey,
      resetTrafficCronKey,
    ],
  });

  data.forEach((configVo) => {
    if (configVo.key === huiWebPortKey) {
      state.dataForm.huiWebPort = configVo.value;
    } else if (configVo.key === huiWebContext) {
      state.dataForm.huiWebContext = configVo.value;
    } else if (configVo.key === hysteria2TrafficTimeKey) {
      state.dataForm.hysteria2TrafficTime = configVo.value;
    } else if (configVo.key === huiCrtPathKey) {
      state.dataForm.huiCrtPath = configVo.value;
    } else if (configVo.key === huiKeyPathKey) {
      state.dataForm.huiKeyPath = configVo.value;
    } else if (configVo.key === resetTrafficCronKey) {
      state.dataForm.resetTrafficCron = configVo.value;
    }
  });

  if (state.dataForm.huiCrtPath != "" && state.dataForm.huiKeyPath != "") {
    state.huiHttps = 1;
  }
};

const handleImport = async (params: UploadRequestOptions) => {
  if (state.fileList.length > 0) {
    try {
      let formData = new FormData();
      formData.append("file", params.file);
      await importConfigApi(formData);
      ElMessage.success(t("common.success"));
      state.fileList = [];
    } catch (e) {
      /* empty */
    } finally {
      await setConfig();
    }
  }
};
const beforeImport = (file: UploadRawFile) => {
  if (!file.name.endsWith(".json")) {
    ElMessage.error("file format not supported");
    return false;
  }
  if (file.size / 1024 / 1024 > 2) {
    ElMessage.error("the file is too big, less than 2 MB");
    return false;
  }
};

const handleExport = async () => {
  try {
    let response = await exportConfigApi();
    const blob = new Blob([response.data], {
      type: "application/octet-stream",
    });
    let url = window.URL.createObjectURL(blob);
    let a = document.createElement("a");
    document.body.appendChild(a);
    a.href = url;
    let dis = response.headers["content-disposition"];
    a.download = dis.split("attachment; filename=")[1];
    a.click();
    window.URL.revokeObjectURL(url);
    ElMessage.success(t("common.success"));
  } catch (e) {
    /* empty */
  }
};

const setCertPath = async () => {
  try {
    const { data } = await hysteria2AcmePathApi();
    const { crtPath, keyPath } = data;
    state.dataForm.huiCrtPath = crtPath;
    state.dataForm.huiKeyPath = keyPath;
  } catch (e) {
    /* empty */
  }
};

const uploadCertFile = async (params: UploadRequestOptions) => {
  try {
    if (
      !params.file.name.endsWith(".crt") &&
      !params.file.name.endsWith(".key")
    ) {
      ElMessage.error("file format not supported");
    }
    if (params.file.size > 1024 * 1024) {
      ElMessage.error("the file is too big");
    }
    let formData = new FormData();
    formData.append("file", params.file);
    const { data } = await uploadCertFileApi(formData);
    if (params.file.name.endsWith(".crt")) {
      state.dataForm.huiCrtPath = data;
    } else if (params.file.name.endsWith(".key")) {
      state.dataForm.huiKeyPath = data;
    }
  } catch (e) {
    /* empty */
  }
};

const handleRestartServer = async () => {
  try {
    ElMessageBox.confirm("Are you sure to restart panel?", "Warning", {
      confirmButtonText: t("common.confirm"),
      cancelButtonText: t("common.cancel"),
      type: "warning",
    }).then(() => {
      restartServerApi();
      ElMessage.success(t("config.restartTip"));
    });
  } catch (e) {
    /* empty */
  }
};

onMounted(() => {
  setConfig();
  if (route.query.focus === "huiHttps") {
    nextTick(() => {
      const input = huiHttpsRef.value.$el.querySelector(".el-input__inner");
      if (input) {
        input.focus();
      }
    });
  }
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
    flex-wrap: wrap;
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

.https-toggle {
  display: flex;
  gap: 12px;
  align-items: center;

  .el-select {
    width: 160px;
  }
}

.ml-2 {
  margin-left: 8px;
}

.el-divider {
  margin: 24px 0;
  border-color: var(--border-color, #e8e8ef);
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
