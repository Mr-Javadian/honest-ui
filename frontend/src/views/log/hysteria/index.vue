<template>
  <div class="page-container">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">{{ $t("route.logHysteria") }}</h2>
      </div>
      <div class="header-actions">
        <el-form ref="queryFormRef" :model="queryParams" inline>
          <el-form-item :label="$t('log.numLine')" prop="numLine">
            <el-select
              v-model="queryParams.numLine"
              @change="setRecords"
              style="width: 120px"
            >
              <el-option label="100" value="100" />
              <el-option label="200" value="200" />
              <el-option label="300" value="300" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button @click="handleExport">
              <template #icon><i-ep-download /></template>
              {{ $t("common.export") }}
            </el-button>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="setRecords">
              <template #icon><i-ep-refresh /></template>
              {{ $t("common.refresh") }}
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>

    <el-card shadow="never" class="content-card">
      <el-table
        v-loading="loading"
        :data="records"
        stripe
        empty-text="No records found"
      >
        <el-table-column
          key="level"
          label="Level"
          align="center"
          prop="level"
          width="100"
        >
          <template #default="{ row }">
            <el-tag
              :type="levelTagType(row.level)"
              size="small"
              effect="dark"
            >
              {{ row.level }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column key="msg" label="Message" prop="msg" min-width="300">
          <template #default="{ row }">
            <span class="log-msg">{{ row.msg }}</span>
          </template>
        </el-table-column>
        <el-table-column
          key="time"
          label="Time"
          align="center"
          prop="time"
          width="180"
        >
          <template #default="{ row }">
            <span class="log-time">{{ row.time }}</span>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script lang="ts">
export default {
  name: "index",
};
</script>

<script setup lang="ts">
import { LogDto, LogHysteria2Vo } from "@/api/log/types";
import { exportLogApi, logHysteria2Api } from "@/api/log";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const state = reactive({
  loading: true,
  total: 0,
  records: [] as LogHysteria2Vo[],
  queryParams: {
    numLine: 100,
  } as LogDto,
});

const { loading, records, queryParams } = toRefs(state);

const levelTagType = (level: string) => {
  switch (level?.toLowerCase()) {
    case "error":
      return "danger";
    case "warn":
    case "warning":
      return "warning";
    case "info":
      return "info";
    case "debug":
      return "success";
    default:
      return "info";
  }
};

const setRecords = async () => {
  try {
    state.loading = true;
    const { data } = await logHysteria2Api(state.queryParams);
    state.records = data.records;
    state.total = data.total;
  } finally {
    state.loading = false;
  }
};

const handleExport = async () => {
  let response = await exportLogApi({ option: 1 });
  try {
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

onMounted(() => {
  setRecords();
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
    :deep(.el-form) {
      display: flex;
      align-items: center;
      gap: 8px;

      .el-form-item {
        margin-bottom: 0;
      }
    }
  }
}

.content-card {
  border-radius: 8px;
  border: 1px solid var(--border-color, #e8e8ef);

  :deep(.el-card__body) {
    padding: 16px;
  }
}

.log-msg {
  font-family: "SF Mono", "Fira Code", "Consolas", monospace;
  font-size: 12px;
  line-height: 1.5;
  color: var(--text-primary, #1a1a2e);
}

.log-time {
  font-family: "SF Mono", "Fira Code", "Consolas", monospace;
  font-size: 12px;
  color: var(--text-secondary, #8b8fa3);
}

:deep(.el-table) {
  font-size: 13px;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
}
</style>
