// Honest-UI version
export const APP_VERSION = "0.5.0";
export const APP_VERSION_PREFIXED = "v0.5.0";

// System settings
interface DefaultSettings {
  /**
   * System title
   */
  title: string;

  /**
   * Whether to show settings
   */
  showSettings: boolean;
  /**
   * Whether to show tags view
   */
  tagsView: boolean;
  /**
   * Whether to fix header
   */
  fixedHeader: boolean;
  /**
   * Whether to show sidebar logo
   */
  sidebarLogo: boolean;
  /**
   * Navbar layout
   */
  layout: string;
  /**
   * Theme color
   */
  themeColor: string;
  /**
   * Theme mode
   */
  theme: string;

  /**
   * Layout size
   */
  size: string;

  /**
   * Language
   */
  language: string;
}

const defaultSettings: DefaultSettings = {
  title: "Honest-UI",
  showSettings: true,
  tagsView: false,
  fixedHeader: false,
  sidebarLogo: true,
  layout: "left",
  themeColor: "#409EFF",
  /**
   *  Theme mode
   *
   * dark: Dark mode
   * light: Light mode
   */
  theme: "dark",
  size: "default", // default |large |small
  language: "en", // zh-cn | en | ru | fa
};

export default defaultSettings;
