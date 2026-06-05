<script setup lang="ts">
import { useAppStore } from "@/store/modules/app";

const appStore = useAppStore();

const sizeOptions = ref([
  { label: "Default", value: "default" },
  { label: "Large", value: "large" },
  { label: "Small", value: "small" },
]);

function handleSizeChange(size: string) {
  appStore.changeSize(size);
  ElMessage.success("Layout size switched successfully");
}
</script>

<template>
  <el-dropdown trigger="click" @command="handleSizeChange">
    <div>
      <svg-icon icon-class="size" />
    </div>
    <template #dropdown>
      <el-dropdown-menu>
        <el-dropdown-item
          v-for="item of sizeOptions"
          :key="item.value"
          :disabled="appStore.size == item.value"
          :command="item.value"
        >
          {{ item.label }}
        </el-dropdown-item>
      </el-dropdown-menu>
    </template>
  </el-dropdown>
</template>
