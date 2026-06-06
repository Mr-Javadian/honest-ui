<script setup lang="ts">
import path from "path-browserify";
import { isExternal } from "@/utils/index";
import AppLink from "./Link.vue";
import { translateRouteTitleI18n } from "@/utils/i18n";
import SvgIcon from "@/components/SvgIcon/index.vue";
import { useRoute } from "vue-router";

const route = useRoute();

const props = defineProps({
  item: { type: Object, required: true },
  basePath: { type: String, required: true },
});

const onlyOneChild = ref<any>();

function hasOneShowingChild(children = [], parent: any) {
  const showingChildren = children.filter((item: any) => {
    if (item.meta?.hidden) return false;
    onlyOneChild.value = item;
    return true;
  });
  if (showingChildren.length === 1) return true;
  if (showingChildren.length === 0) {
    onlyOneChild.value = { ...parent, path: "", noShowingChildren: true };
    return true;
  }
  return false;
}

function resolvePath(routePath: string) {
  if (isExternal(routePath)) return routePath;
  if (isExternal(props.basePath)) return props.basePath;
  return path.resolve(props.basePath, routePath);
}

const isActive = (itemPath: string) => {
  const resolved = resolvePath(itemPath);
  return route.path === resolved || route.path.startsWith(resolved + "/");
};
</script>

<template>
  <div v-if="!item.meta || !item.meta.hidden">
    <template v-if="hasOneShowingChild(item.children, item) && (!onlyOneChild.children || onlyOneChild.noShowingChildren)">
      <app-link v-if="onlyOneChild.meta" :to="resolvePath(onlyOneChild.path)">
        <el-menu-item :index="resolvePath(onlyOneChild.path)" :class="{ 'is-active-sidebar': isActive(onlyOneChild.path) }">
          <svg-icon v-if="onlyOneChild.meta && onlyOneChild.meta.icon" :icon-class="onlyOneChild.meta.icon" />
          <template #title>
            <span class="menu-title">{{ translateRouteTitleI18n(onlyOneChild.meta.title) }}</span>
          </template>
        </el-menu-item>
      </app-link>
    </template>

    <el-sub-menu v-else :index="resolvePath(item.path)" teleported>
      <template #title>
        <svg-icon v-if="item.meta && item.meta.icon" :icon-class="item.meta.icon" />
        <span v-if="item.meta && item.meta.title" class="menu-title">{{ translateRouteTitleI18n(item.meta.title) }}</span>
      </template>
      <sidebar-item
        v-for="child in item.children"
        :key="child.path"
        :item="child"
        :base-path="resolvePath(child.path)"
      />
    </el-sub-menu>
  </div>
</template>
