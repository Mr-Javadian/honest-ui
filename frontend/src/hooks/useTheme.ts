import { ref } from "vue";

type Theme = "light" | "dark" | "ultra-dark";

const STORAGE_KEY = "app-theme";

function readTheme(): Theme {
  try {
    const val = localStorage.getItem(STORAGE_KEY);
    if (val === "light" || val === "dark" || val === "ultra-dark") return val;
  } catch {}
  return "dark";
}

function writeTheme(t: Theme) {
  try {
    localStorage.setItem(STORAGE_KEY, t);
  } catch {}
}

function applyTheme(t: Theme) {
  const html = document.documentElement;
  html.classList.remove("dark");
  html.removeAttribute("data-theme");
  if (t !== "light") {
    html.classList.add("dark");
    if (t === "ultra-dark") {
      html.setAttribute("data-theme", "ultra-dark");
    }
  }
}

const initialTheme = readTheme();
applyTheme(initialTheme);

export function useAppTheme() {
  const theme = ref<Theme>(initialTheme);

  const isDark = computed(() => theme.value !== "light");
  const isUltra = computed(() => theme.value === "ultra-dark");

  function setTheme(t: Theme) {
    theme.value = t;
    writeTheme(t);
    applyTheme(t);
  }

  function cycleTheme() {
    if (theme.value === "light") setTheme("dark");
    else if (theme.value === "dark") setTheme("ultra-dark");
    else setTheme("light");
  }

  return { theme, isDark, isUltra, setTheme, cycleTheme };
}
