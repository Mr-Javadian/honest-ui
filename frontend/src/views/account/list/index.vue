<template>
  <div class="app-container clients-page">
    <el-row :gutter="[16, 16]">
      <el-col :span="24">
        <el-card shadow="never" class="summary-card">
          <el-row :gutter="16">
            <el-col :xs="12" :sm="8" :md="4">
              <div class="stat-item">
                <div class="stat-value">{{ total }}</div>
                <div class="stat-label">{{ $t("account.role") === "Role" ? "Total" : $t("common.id") === "ID" ? "Total" : $t("common.all") }}</div>
              </div>
            </el-col>
            <el-col :xs="12" :sm="8" :md="4">
              <div class="stat-item">
                <div class="stat-value">{{ onlineCount }}</div>
                <div class="stat-label">{{ $t("account.online") }}</div>
              </div>
            </el-col>
            <el-col :xs="12" :sm="8" :md="4">
              <div class="stat-item">
                <div class="stat-value">{{ offlineCount }}</div>
                <div class="stat-label">{{ $t("account.offline") }}</div>
              </div>
            </el-col>
          </el-row>
        </el-card>
      </el-col>

      <el-col :span="24">
        <el-card shadow="never" class="main-card">
          <template #header>
            <div class="card-toolbar">
              <el-button type="primary" :icon="Plus" @click="handleAdd">{{ $t("common.add") }}</el-button>
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

              <div style="margin-left: auto; display: flex; gap: 8px; align-items: center;">
                <el-input
                  v-model="searchKey"
                  :placeholder="$t('common.search')"
                  clearable
                  :prefix-icon="Search"
                  style="width: 200px"
                  size="default"
                  @input="handleSearchDebounced"
                />
              </div>
            </div>
          </template>

          <el-table
            v-loading="loading"
            :data="records"
            stripe
            style="width: 100%"
            @selection-change="handleSelectionChange"
          >
            <el-table-column type="selection" width="40" />

            <el-table-column :label="$t('common.id')" align="center" prop="id" width="60" />

            <el-table-column :label="$t('account.remark')" align="center" prop="remark" min-width="100" />

            <el-table-column :label="$t('account.username')" align="center" prop="username" min-width="120">
              <template #default="scope">
                <div class="client-cell">
                  <span class="client-email">{{ scope.row.username }}</span>
                </div>
              </template>
            </el-table-column>

            <el-table-column :label="$t('common.deleted')" align="center" width="80">
              <template #default="scope">
                <el-switch
                  v-model="scope.row.deleted"
                  :active-value="0"
                  :inactive-value="1"
                  size="small"
                  @change="toggleEnable(scope.row)"
                />
              </template>
            </el-table-column>

            <el-table-column :label="$t('account.onlineStatus')" align="center" width="90">
              <template #default="scope">
                <el-tag v-if="scope.row.online" type="success" size="small">{{ $t("account.online") }}</el-tag>
                <el-tag v-else type="info" size="small">{{ $t("account.offline") }}</el-tag>
              </template>
            </el-table-column>

            <el-table-column :label="$t('account.quota')" align="center" prop="quota" width="100">
              <template #default="scope">
                <el-tag>{{ formatBytes(scope.row.quota) }}</el-tag>
              </template>
            </el-table-column>

            <el-table-column :label="$t('account.download')" align="center" width="90">
              <template #default="scope">
                <span class="traffic-down">{{ formatBytes(scope.row.download) }}</span>
              </template>
            </el-table-column>

            <el-table-column :label="$t('account.upload')" align="center" width="90">
              <template #default="scope">
                <span class="traffic-up">{{ formatBytes(scope.row.upload) }}</span>
              </template>
            </el-table-column>

            <el-table-column :label="$t('account.remaining') || 'Remaining'" align="center" width="100">
              <template #default="scope">
                <el-tag v-if="remainingBytes(scope.row) === '∞'" type="info" size="small">∞</el-tag>
                <el-tag v-else :type="remainingColor(scope.row)" size="small">{{ remainingBytes(scope.row) }}</el-tag>
              </template>
            </el-table-column>

            <el-table-column :label="$t('account.kickUtilTimeLast') || 'Remaining'" align="center" width="120">
              <template #default="scope">
                {{ calculateTimeDifference(scope.row.kickUtilTime) }}
              </template>
            </el-table-column>

            <el-table-column :label="$t('account.expireTime')" align="center" width="130">
              <template #default="scope">
                <el-tag v-if="!scope.row.expireTime" type="info" size="small">∞</el-tag>
                <el-tag v-else :type="expiryColor(scope.row)" size="small">{{ timestampToDateTime(scope.row.expireTime) }}</el-tag>
              </template>
            </el-table-column>

            <el-table-column :label="$t('account.loginAt')" align="center" width="130">
              <template #default="scope">
                {{ scope.row.loginAt ? timestampToDateTime(scope.row.loginAt) : "-" }}
              </template>
            </el-table-column>

            <el-table-column :label="$t('common.createTime')" align="center" width="130">
              <template #default="scope">
                {{ timestampToDateTime(scope.row.createTime) }}
              </template>
            </el-table-column>

            <el-table-column :label="$t('common.operate')" align="center" width="300">
              <template #default="scope">
                <div class="action-buttons">
                  <el-tooltip :content="$t('common.nodeQrCode')" placement="top">
                    <el-button text size="small" :icon="Plus" @click="handleInfo(scope.row)" />
                  </el-tooltip>
                  <el-tooltip :content="$t('common.subscribe')" placement="top">
                    <el-button text size="small" :icon="Link" @click="handleSubscribe(scope.row)" />
                  </el-tooltip>
                  <el-tooltip :content="$t('common.nodeUrl')" placement="top">
                    <el-button text size="small" :icon="Share" @click="handleNodeUrl(scope.row)" />
                  </el-tooltip>
                  <el-tooltip :content="$t('common.resetTraffic')" placement="top">
                    <el-button text size="small" :icon="Refresh" @click="resetTraffic(scope.row)" />
                  </el-tooltip>
                  <el-tooltip :content="$t('common.edit')" placement="top">
                    <el-button text size="small" :icon="Edit" @click="handleUpdate(scope.row)" />
                  </el-tooltip>
                  <el-tooltip :content="$t('common.delete')" placement="top">
                    <el-button text size="small" :icon="Delete" @click="handleDelete(scope.row)" style="color:var(--el-color-danger)" />
                  </el-tooltip>
                  <el-dropdown trigger="click" placement="bottom-end">
                    <el-button text size="small" :icon="MoreFilled" />
                    <template #dropdown>
                      <el-dropdown-menu>
                        <el-dropdown-item @click="handleKick(scope.row)">{{ $t("account.kick") }}</el-dropdown-item>
                        <el-dropdown-item
                          v-if="calculateTimeDifference(scope.row.kickUtilTime) !== '-'"
                          @click="confirmReleaseKick(scope.row)"
                        >{{ $t("account.releaseKick") }}</el-dropdown-item>
                      </el-dropdown-menu>
                    </template>
                  </el-dropdown>
                </div>
              </template>
            </el-table-column>
          </el-table>

          <pagination
            v-if="total > 0"
            :total="total"
            v-model:page="queryParams.pageNum"
            v-model:limit="queryParams.pageSize"
            @pagination="handleQuery"
          />
        </el-card>
      </el-col>
    </el-row>

    <!-- Add/Edit Dialog -->
    <el-dialog
      :title="dialog.title"
      v-model="dialog.visible"
      width="620px"
      append-to-body
      @close="closeDialog"
    >
      <el-form
        ref="dataFormRef"
        :rules="dialog.title === t('common.add') ? dataFormAddRules : dataFormUpdateRules"
        :model="dataForm"
        label-width="100px"
      >
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item :label="$t('account.remark')" prop="remark">
              <el-input v-model="dataForm.remark" :placeholder="$t('account.remark')" maxlength="50" clearable />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="$t('account.username')" prop="username">
              <el-input v-model="dataForm.username" :placeholder="$t('account.username')" maxlength="50" clearable />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item :label="$t('account.pass')" prop="pass">
              <el-input
                v-model="dataForm.pass"
                :placeholder="$t('account.pass')"
                maxlength="50"
                clearable
                type="password"
                show-password
                ref="dataFormPassRef"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="$t('account.conPass')" prop="conPass">
              <el-input
                v-model="dataForm.conPass"
                :placeholder="$t('account.conPass')"
                maxlength="50"
                clearable
                type="password"
                show-password
                ref="dataFormConPassRef"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item :label="$t('account.quota')" prop="quota">
              <unit-select :setValue="setQuota" :valueTmp="quotaTmp" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="$t('account.deviceNo')" prop="deviceNo">
              <el-input-number
                v-model="dataForm.deviceNo"
                :placeholder="$t('account.deviceNo')"
                :min="1"
                :controls="false"
                :precision="0"
                clearable
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item :label="$t('account.expireTime')" prop="expireTime">
              <el-date-picker
                v-model="dataForm.expireTime"
                type="datetime"
                :placeholder="$t('account.expireTime')"
                value-format="x"
                :shortcuts="shortcuts"
                clearable
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="$t('common.deleted')" prop="deleted">
              <el-radio-group v-model="dataForm.deleted">
                <el-radio :label="0">{{ $t("common.enable") }}</el-radio>
                <el-radio :label="1">{{ $t("common.disable") }}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">{{ $t("common.confirm") }}</el-button>
        <el-button @click="closeDialog">{{ $t("common.cancel") }}</el-button>
      </template>
    </el-dialog>

    <!-- Kick Dialog -->
    <el-dialog
      :title="dialogKick.title"
      v-model="dialogKick.visible"
      width="600px"
      append-to-body
      @close="closeDialogKick"
    >
      <el-form ref="kickFormRef" :model="kickForm" label-width="100px">
        <el-form-item :label="$t('account.kickUtilTime')" prop="kickUtilTime">
          <el-date-picker
            v-model="kickForm.kickUtilTime"
            type="datetime"
            :placeholder="$t('account.kickUtilTime')"
            value-format="x"
            :shortcuts="shortcutsKick"
            clearable
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitKickForm">{{ $t("common.confirm") }}</el-button>
        <el-button @click="closeDialogKick">{{ $t("common.cancel") }}</el-button>
      </template>
    </el-dialog>

    <!-- QR Code Dialog -->
    <el-dialog
      :title="qrCodeDialog.title"
      v-model="qrCodeDialog.visible"
      width="600px"
      append-to-body
      @close="qrCodeDialog.visible = false"
    >
      <div style="text-align: center">
        <el-image style="width: 300px; height: 300px" :src="qrCodeSrc" />
      </div>
      <template #footer>
        <el-button type="primary" @click="qrCodeDialog.visible = false">{{ $t("common.confirm") }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts">
export default {
  name: "index",
};
</script>

<script setup lang="ts">
import {
  AccountForm,
  AccountPageDto,
  AccountUpdateDto,
  AccountVo,
  KickAccountForm,
} from "@/api/account/types";
import {
  saveAccountApi,
  deleteAccountApi,
  getAccountApi,
  pageAccountApi,
  updateAccountApi,
  exportAccountApi,
  releaseKickAccountApi,
  importAccountApi,
  resetTrafficApi,
} from "@/api/account";
import { Search, Plus, Refresh, Edit, Share, Link, MoreFilled, Delete } from "@element-plus/icons-vue";
import {
  timestampToDateTime,
  getMonthLater,
  getWeekLater,
  getYearLater,
  calculateTimeDifference,
  getHourLater,
  getDayLater,
} from "@/utils/time";
import { formatBytes } from "@/utils/byte";

import {
  hysteria2KickApi,
  hysteria2SubscribeUrlApi,
  hysteria2UrlApi,
} from "@/api/hysteria2";
import {
  UploadFile,
  UploadRawFile,
  UploadRequestOptions,
} from "element-plus/lib/components";
import { useI18n } from "vue-i18n";

import {
  Hysteria2SubscribeUrlDto,
  Hysteria2UrlDto,
} from "@/api/hysteria2/types";
import copy from "copy-to-clipboard";
import { useRoute } from "vue-router";

const { t } = useI18n();
const route = useRoute();
const queryFormRef = ref(ElForm);
const dataFormRef = ref(ElForm);
const kickFormRef = ref(ElForm);
const dataFormPassRef = ref(ElInput);
const dataFormConPassRef = ref(ElInput);

const onlineCount = ref(0);
const offlineCount = ref(0);
const searchKey = ref("");
let searchTimer: ReturnType<typeof setTimeout> | null = null;

const dataFormAddRules = {
  remark: [
    {
      min: 0,
      max: 32,
      message: "Remark format is incorrect",
      trigger: ["change", "blur"],
    },
  ],
  username: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
    {
      pattern: /^[a-zA-Z0-9!@#$%^&*()_+=-]{6,32}$/,
      message: "Username format is incorrect",
      trigger: ["change", "blur"],
    },
  ],
  pass: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
    {
      pattern: /^[a-zA-Z0-9!@#$%^&*()_+=-]{6,32}$/,
      message: "Pass format is incorrect",
      trigger: ["change", "blur"],
    },
  ],
  conPass: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
    {
      pattern: /^[a-zA-Z0-9!@#$%^&*()_+=-]{6,32}$/,
      message: "ConPass format is incorrect",
      trigger: ["change", "blur"],
    },
  ],
  expireTime: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
  ],
  deviceNo: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
  ],
  deleted: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
  ],
};

const dataFormUpdateRules = {
  remark: [
    {
      min: 0,
      max: 32,
      message: "Remark format is incorrect",
      trigger: ["change", "blur"],
    },
  ],
  username: [
    {
      pattern: /^[a-zA-Z0-9!@#$%^&*()_+=-]{6,32}$/,
      message: "Username format is incorrect",
      trigger: ["change", "blur"],
    },
  ],
  pass: [
    {
      pattern: /^[a-zA-Z0-9!@#$%^&*()_+=-]{6,32}$/,
      message: "Pass format is incorrect",
      trigger: ["change", "blur"],
    },
  ],
  conPass: [
    {
      pattern: /^[a-zA-Z0-9!@#$%^&*()_+=-]{6,32}$/,
      message: "Pass format is incorrect",
      trigger: ["change", "blur"],
    },
  ],
};

const shortcuts = [
  { text: "A week later", value: getWeekLater },
  { text: "A month later", value: getMonthLater },
  { text: "A year later", value: getYearLater },
];

const shortcutsKick = [
  { text: "A hour later", value: getHourLater },
  { text: "A day later", value: getDayLater },
  { text: "A week later", value: getWeekLater },
  { text: "A month later", value: getMonthLater },
];

const state = reactive({
  loading: true,
  total: 0,
  records: [] as AccountVo[],
  dialog: {
    visible: false,
  } as DialogType,
  dialogKick: {
    visible: false,
  } as DialogType,
  dataForm: {
    quota: 0,
    expireTime: getMonthLater(),
    deviceNo: 6,
    deleted: 0,
  } as AccountForm,
  kickForm: {
    kickUtilTime: getHourLater(),
  } as KickAccountForm,
  queryParams: {
    remark: undefined,
    username: undefined,
    deleted: undefined,
    pageNum: 1,
    pageSize: 10,
  } as AccountPageDto,
  quotaTmp: 0,
  fileList: [] as UploadFile[],
  qrCodeDialog: {
    title: "QR Code",
    visible: false,
  } as DialogType,
  qrCodeSrc: "",
});

const {
  loading,
  total,
  records,
  dialog,
  dialogKick,
  dataForm,
  kickForm,
  queryParams,
  quotaTmp,
  fileList,
  qrCodeDialog,
  qrCodeSrc,
} = toRefs(state);

function remainingBytes(row: AccountVo): string {
  const quota = row.quota || 0;
  const used = (row.download || 0) + (row.upload || 0);
  if (quota <= 0) return "∞";
  const remaining = quota - used;
  return remaining > 0 ? formatBytes(remaining) : "0";
}

function remainingColor(row: AccountVo): "success" | "warning" | "danger" | "info" {
  const quota = row.quota || 0;
  if (quota <= 0) return "info";
  const used = (row.download || 0) + (row.upload || 0);
  const ratio = used / quota;
  if (ratio >= 1) return "danger";
  if (ratio >= 0.85) return "warning";
  return "success";
}

function expiryColor(row: AccountVo): "success" | "warning" | "danger" | "info" {
  if (!row.expireTime) return "info";
  const now = Date.now();
  if (row.expireTime <= now) return "danger";
  if (row.expireTime - now < 86400000 * 3) return "warning";
  return "success";
}

const resetDataForm = () => {
  Object.assign(state.dataForm, {
    id: undefined,
    quota: 0,
    expireTime: getMonthLater(),
    deleted: 0,
  });
  quotaTmp.value = 0;
};

const handleQuery = async () => {
  state.loading = true;
  try {
    const { data } = await pageAccountApi(state.queryParams);
    state.records = data.records;
    state.total = data.total;
    let online = 0;
    let offline = 0;
    for (const r of data.records) {
      if (r.online) online++;
      else offline++;
    }
    onlineCount.value = online;
    offlineCount.value = offline;
  } finally {
    state.loading = false;
  }
};

const resetQuery = () => {
  queryFormRef.value.resetFields();
  handleQuery();
};

function handleSearchDebounced() {
  if (searchTimer) clearTimeout(searchTimer);
  searchTimer = setTimeout(() => {
    state.queryParams.pageNum = 1;
    handleQuery();
  }, 300);
}

const handleAdd = () => {
  state.dialog = {
    title: t("common.add"),
    visible: true,
  };
};

const handleUpdate = async (row: { [key: string]: any }) => {
  const id = row.id;
  const { data } = await getAccountApi({ id: id });
  Object.assign(state.dataForm, data);
  quotaTmp.value = data.quota;
  dialog.value = {
    title: t("common.update"),
    visible: true,
  };
};

const setQuota = (newQuota: number) => {
  state.dataForm.quota = newQuota;
};

const submitForm = () => {
  dataFormRef.value.validate((valid: any) => {
    if (valid) {
      const accountId = state.dataForm.id;
      let accountUpdateDto: AccountUpdateDto = { ...state.dataForm };
      if (accountId) {
        updateAccountApi(accountUpdateDto).then(() => {
          ElMessage.success(t("common.success"));
          closeDialog();
          handleQuery();
        });
      } else {
        saveAccountApi(accountUpdateDto).then(() => {
          ElMessage.success(t("common.success"));
          closeDialog();
          handleQuery();
        });
      }
    }
  });
};

const submitKickForm = () => {
  kickFormRef.value.validate((valid: any) => {
    if (valid) {
      const params = { ...state.kickForm };
      hysteria2KickApi(params).then(() => {
        ElMessage.success(t("common.success"));
        closeDialogKick();
        handleQuery();
      });
    }
  });
};

const handleDelete = (row: { [key: string]: any }) => {
  const id = row.id;
  const username = row.username;
  ElMessageBox.confirm(
    "Are you sure to delete the data item with the username「" +
      username + "」?",
    "Warning",
    {
      confirmButtonText: t("common.confirm"),
      cancelButtonText: t("common.cancel"),
      type: "warning",
    }
  )
    .then(() => {
      deleteAccountApi({ id: id }).then(() => {
        ElMessage.success(t("common.success"));
        handleQuery();
      });
    })
    .catch(() => ElMessage.info(t("common.cancel")));
};

const handleKick = (row: { [key: string]: any }) => {
  state.kickForm.ids = [row.id];
  dialogKick.value = {
    title: t("account.kickTip"),
    visible: true,
  };
};

const confirmReleaseKick = (row: { [key: string]: any }) => {
  releaseKickAccountApi({ id: row.id }).then(() => {
    ElMessage.success(t("account.releaseSuccess"));
    handleQuery();
  });
};

const closeDialog = () => {
  dialog.value.visible = false;
  dataFormRef.value.resetFields();
  dataFormRef.value.clearValidate();
  if (dialog.value.title == t("common.update")) {
    resetDataForm();
  }
};

const closeDialogKick = () => {
  dialogKick.value.visible = false;
  kickFormRef.value.resetFields();
  kickFormRef.value.clearValidate();
};

const handleImport = (params: UploadRequestOptions) => {
  if (state.fileList.length > 0) {
    let formData = new FormData();
    formData.append("file", params.file);
    importAccountApi(formData).then(() => {
      ElMessage.success(t("common.success"));
    });
    state.fileList = [];
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

const handleExport = () => {
  exportAccountApi().then((res) => {
    const blob = new Blob([res.data], {
      type: "application/octet-stream",
    });
    let url = window.URL.createObjectURL(blob);
    let a = document.createElement("a");
    document.body.appendChild(a);
    a.href = url;
    let dis = res.headers["content-disposition"];
    a.download = dis.split("attachment; filename=")[1];
    a.click();
    window.URL.revokeObjectURL(url);
    ElMessage.success(t("common.success"));
  });
};

const handleSubscribe = async (row: { [key: string]: any }) => {
  try {
    const dto: Hysteria2SubscribeUrlDto = {
      accountId: row.id,
      protocol: window.location.protocol,
      host: window.location.host,
    };
    const { data } = await hysteria2SubscribeUrlApi(dto);
    copy(data.url);
    ElMessage.success(t("common.copySuccess"));
  } catch (e) {
    /* empty */
  }
};

const handleNodeUrl = async (row: { [key: string]: any }) => {
  try {
    const dto: Hysteria2UrlDto = {
      accountId: row.id,
      hostname: window.location.hostname,
    };
    const { data } = await hysteria2UrlApi(dto);
    copy(data.url);
    ElMessage.success(t("common.copySuccess"));
  } catch (e) {
    /* empty */
  }
};

const handleInfo = async (row: { [key: string]: any } | null) => {
  if (!row) {
    ElMessage.info("Coming soon");
    return;
  }
  try {
    const dto: Hysteria2UrlDto = {
      accountId: row.id,
      hostname: window.location.hostname,
    };
    const { data } = await hysteria2UrlApi(dto);
    state.qrCodeSrc = "data:image/png;base64," + data.qrCode;
    state.qrCodeDialog.visible = true;
  } catch (e) {
    /* empty */
  }
};

const handleQrCode = async (row: { [key: string]: any }) => {
  try {
    const dto: Hysteria2UrlDto = {
      accountId: row.id,
      hostname: window.location.hostname,
    };
    const { data } = await hysteria2UrlApi(dto);
    state.qrCodeSrc = "data:image/png;base64," + data.qrCode;
    state.qrCodeDialog.visible = true;
  } catch (e) {
    /* empty */
  }
};

const resetTraffic = async (row: { [key: string]: any }) => {
  try {
    await resetTrafficApi({ id: row.id });
    ElMessage.success(t("common.success"));
    await handleQuery();
  } catch (e) {
    /* empty */
  }
};

const toggleEnable = async (row: AccountVo) => {
  const dto: AccountUpdateDto = {
    id: row.id,
    username: row.username,
    pass: row.pass,
    conPass: row.conPass,
    quota: row.quota,
    deviceNo: row.deviceNo,
    expireTime: row.expireTime,
    deleted: row.deleted,
    remark: row.remark,
  };
  try {
    await updateAccountApi(dto);
    ElMessage.success(t("common.success"));
  } catch (e) {
    handleQuery();
  }
};

const handleSelectionChange = (selection: AccountVo[]) => {
  // Handle row selection changes
};

onMounted(() => {
  handleQuery();
  if (route.query.focus === "change-pass") {
    nextTick(() => {
      handleUpdate({ id: 1 }).then(() => {
        setTimeout(() => {
          const inputPass = dataFormPassRef.value.$el.querySelector(
            ".el-input__wrapper input"
          );
          if (inputPass) {
            inputPass.focus();
          }
        }, 50);
      });
    });
  }
});
</script>

<style lang="scss" scoped>
.clients-page {
  padding: 8px;
}

.summary-card {
  margin-bottom: 0;
  border-radius: 12px;
}

.stat-item {
  text-align: center;
  padding: 8px 0;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  line-height: 1.2;
  color: var(--el-text-color-primary);
}

.stat-label {
  font-size: 13px;
  color: var(--el-text-color-secondary);
  margin-top: 4px;
}

.main-card {
  border-radius: 12px;
}

.main-card :deep(.el-card__header) {
  padding: 12px 20px;
  border-bottom: 1px solid var(--el-border-color-light);
}

.card-toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.client-cell {
  display: flex;
  flex-direction: column;
}

.client-email {
  font-weight: 500;
}

.action-buttons {
  display: flex;
  align-items: center;
  gap: 2px;
  flex-wrap: nowrap;
}

.traffic-up {
  color: var(--el-color-success);
}

.traffic-down {
  color: var(--el-color-primary);
}

:deep(.el-table) {
  border-radius: 8px;
}

:deep(.el-table th.el-table__cell) {
  background-color: var(--el-fill-color-light);
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--el-text-color-secondary);
}

:deep(.el-table__row) {
  transition: background-color 0.2s;
}

:deep(.el-table__row:hover) {
  background-color: var(--el-fill-color-lighter);
}

:deep(.el-tag) {
  border-radius: 6px;
}
</style>
