export default {
  route: {
    overview: "پیش‌نمایش",
    clients: "کاربران",
    clientsList: "کاربران",
    panelSettings: "تنظیمات پنل",
    hysteria: "Hysteria",
    hysteriaList: "تنظیمات Hysteria",
    config: "سیستم",
    configList: "عمومی",
    log: "لاگ‌ها",
    logSystem: "سیستم",
    logHysteria: "Hysteria",
    telegram: "تلگرام",
    telegramList: "ربات تلگرام",
  },
  login: {
    title: "Honest-UI",
    username: "نام کاربری",
    password: "رمز عبور",
    login: "ورود",
  },
  navbar: {
    logout: "خروج",
    theme: "تِم",
  },
  common: {
    id: "شناسه",
    createTime: "تاریخ ایجاد",
    operate: "عملیات",
    edit: "ویرایش",
    delete: "حذف",
    deleted: "وضعیت",
    all: "همه",
    enable: "فعال",
    disable: "غیرفعال",
    search: "جستجو",
    reset: "بازنشانی",
    add: "افزودن",
    confirm: "تأیید",
    cancel: "لغو",
    copySuccess: "کپی با موفقیت انجام شد",
    subscribe: "اشتراک",
    subscribeQrCode: "QR کد اشتراک",
    nodeUrl: "آدرس نود",
    nodeQrCode: "QR کد نود",
    resetTraffic: "بازنشانی ترافیک",
    import: "ورود",
    export: "خروج",
    save: "ذخیره",
    update: "به‌روزرسانی",
    downloadSuccess: "دانلود با موفقیت انجام شد",
    wait: "نسخه در حال تغییر است، لطفاً لحظه‌ای صبر کنید",
    enableSuccess: "Hysteria2 با موفقیت شروع شد",
    disableSuccess: "Hysteria2 با موفقیت متوقف شد",
    success: "موفق",
    refresh: "تازه‌سازی",
    yes: "بله",
    no: "خیر",
    securityRisk: "مخاطرات امنیتی",
    defaultPassTip: `لطفاً در اسرع وقت رمز عبور پیش‌فرض را تغییر دهید. توصیه می‌شود یک رمز عبور قوی برای محافظت از امنیت حساب خود تنظیم کنید. <a href="/#/clients/list?focus=change-pass" style="color: #00BFFF">اینجا کلیک کنید</a> برای تغییر`,
    noHttpsTip: `وب‌سایت شما از HTTPS استفاده نمی‌کند که باعث ناامنی انتقال داده می‌شود. لطفاً در اسرع وقت HTTPS را فعال کنید تا از اطلاعات کاربران محافظت شود. <a href="/#/config/list?focus=huiHttps" style="color: #00BFFF">اینجا کلیک کنید</a> برای فعال‌سازی`,
  },
  info: {
    expireTime: "y-M-d H:m:s",
    greeting1: "هوای خنک و تازه، انرژی شما را برای روز بیدار می‌کند🌅!",
    greeting2: "صبح بخیر،",
    greeting3: "بعد از ظهر بخیر،",
    greeting4: "عصر بخیر،",
    greeting5: "می‌خواهم یک ستاره دنباله‌دار باشم، تاریکی را بشکافم، فقط برای روشن کردن رویاهای تو، شب بخیر🌛!",
  },
  account: {
    remark: "یادداشت",
    username: "نام کاربری",
    pass: "رمز عبور",
    conPass: "رمز اتصال",
    quota: "سهمیه",
    download: "دانلود",
    upload: "آپلود",
    expireTime: "تاریخ انقضا",
    kickUtilTimeLast: "زمان باقی‌مانده آفلاین",
    kickUtilTime: "زمان آفلاین",
    deviceNo: "محدودیت دستگاه",
    onlineStatus: "وضعیت آنلاین",
    online: "آنلاین",
    offline: "آفلاین",
    device: "دستگاه‌های آنلاین",
    role: "نقش",
    unit: "واحد",
    loginAt: "آخرین ورود",
    conAt: "آخرین اتصال",
    createTime: "تاریخ ایجاد",
    releaseSuccess: "آزادسازی با موفقیت انجام شد",
    kick: "قطع اتصال",
    kickTip: "اجبار کاربر به خروج",
    releaseKick: "آزادسازی",
    releaseKickTip: "حذف وضعیت آفلاین",
  },
  config: {
    huiWebPort: "پورت وب Honest-UI",
    huiWebContext: "مسیر وب Honest-UI",
    hysteria2TrafficTime: "زمان ترافیک Hysteria2",
    huiCrtPath: "مسیر فایل CRT Honest-UI",
    huiKeyPath: "مسیر فایل KEY Honest-UI",
    uploadCrtFile: "آپلود فایل CRT",
    uploadKeyFile: "آپلود فایل KEY",
    restartServer: "راه‌اندازی مجدد پنل",
    restartTip: "در حال راه‌اندازی مجدد، لطفاً صفحه را تازه کنید",
    useHysteria2Cert: "استفاده از گواهی Hysteria2",
    huiHttps: "فعال‌سازی HTTPS در پنل",
    resetTrafficCron: "برنامه زمان‌بندی بازنشانی ترافیک",
    resetTrafficCronTip:
      "عبارت برنامه زمان‌بندی، مرجع: https://pkg.go.dev/github.com/robfig/cron/v3",
    resetTrafficMonth: "اجرا یک بار در ماه، نیمه‌شب، اول ماه",
    resetTrafficWeek: "اجرا یک بار در هفته، نیمه‌شب بین شنبه/یکشنبه",
  },
  monitor: {
    huiVersion: "نسخه Honest-UI",
    cpuPercent: "مصرف CPU",
    memPercent: "مصرف حافظه",
    diskPercent: "مصرف دیسک",
    hysteria2UserTotal: "تعداد کاربران آنلاین",
    hysteria2DeviceTotal: "تعداد دستگاه‌های آنلاین",
    hysteria2Version: "نسخه Hysteria2",
    hysteria2Running: "وضعیت Hysteria2",
    hysteria2RunningTrue: "در حال اجرا",
    hysteria2RunningFalse: "متوقف",
  },
  log: {
    numLine: "تعداد خطوط",
  },
  telegram: {
    placeholder: "محل نگهدارنده",
    enable: "فعال",
    disable: "غیرفعال",
    telegramEnable: "فعال/غیرفعال",
    telegramToken: "توکن تلگرام",
    telegramChatId: "ChatId تلگرام",
    telegramJob: "لیست وظایف",
    telegramLoginJob: "اعلان ورود",
    telegramLoginJobEnable: "فعال/غیرفعال",
    telegramLoginJobText: "قالب محتوا",
  },
  hysteria: {
    enable: "فعال",
    disable: "غیرفعال",
    addConfigItem: "افزودن آیتم تنظیمات",
    hysteria2Version: "نسخه Hysteria2",
    hysteria2Running: "وضعیت Hysteria2",
    hysteria2ChangeVersion: "تغییر",
    addOutbound: "افزودن خروجی",
    extension: "افزونه",
    listen: "شنود",
    tls: "TLS",
    obfs: "مبهم‌سازی",
    quic: "پارامترهای QUIC",
    bandwidth: "پهنای باند",
    speedTest: "تست سرعت",
    udp: "UDP",
    resolver: "حل‌کننده",
    sniff: "بوییدن پروتکل",
    acl: "ACL",
    outbounds: "خروجی‌ها",
    http: "API آمار ترافیک (HTTP)",
    masquerade: "نقاب",
    config: {
      enable: "فعال/غیرفعال",
      remark: "یادداشت",
      portHopping:
        "Port Hopping، چند پورت مجزا: 1234,5678,9012; محدوده پورت: 20000-50000; ترکیبی از هر دو: 1234,5000-6000,7044,8000-9000",
      clashExtension: "افزونه اشتراک Clash",
      listen:
        "هنگامی که آدرس IP حذف شود، سرور به تمام رابط‌ها، هم IPv4 و هم IPv6 گوش می‌دهد. برای گوش دادن فقط IPv4، از 0.0.0.0:443 استفاده کنید. برای گوش دادن فقط IPv6، از [::]:443 استفاده کنید. Hysteria >= 2.8.0 از پورت هاپینگ پشتیبانی می‌کند.",
      tlsType: "نوع TLS",
      tls: {
        cert: "مسیر فایل گواهی.",
        key: "مسیر فایل کلید.",
        sniGuard:
          'SNI ارائه شده توسط کلاینت را تأیید کنید. اتصال را فقط زمانی بپذیرید که با گواهی مطابقت داشته باشد. در غیر این صورت دست‌دهی TLS را خاتمه دهید. برای اعمال این رفتار، روی strict تنظیم کنید. برای غیرفعال کردن کامل، روی disable تنظیم کنید. پیش‌فرض dns-san است که این ویژگی را فقط زمانی فعال می‌کند که گواهی حاوی "Subject Alternative Name" با نام دامنه باشد.',
      },
      acme: {
        domains: "دامنه‌ها",
        email: "ایمیل",
        ca: "CA مورد استفاده. می‌تواند letsencrypt یا zerossl باشد.",
        listenHost:
          "آدرس میزبان (بدون پورت) برای شنود چالش ACME. اگر حذف شود، سرور به تمام رابط‌ها گوش می‌دهد.",
        dir: "مسیر ذخیره‌سازی کلید حساب ACME و گواهی‌ها.",
        type: "نوع چالش ACME. می‌تواند http، tls یا dns باشد.",
        http: {
          altPort:
            "پورت شنود برای چالش‌های HTTP. (توجه: تغییر به پورتی غیر از 80 نیاز به پورت فورواردینگ یا پروکسی معکوس HTTP دارد، در غیر این صورت چالش شکست می‌خورد!)",
        },
        tls: {
          altPort:
            "پورت شنود برای چالش‌های TLS-ALPN. (توجه: تغییر به پورتی غیر از 443 نیاز به پورت فورواردینگ یا پروکسی معکوس TLS دارد، در غیر این صورت چالش شکست می‌خورد!)",
        },
        dns: {
          name: "ارائه‌دهنده DNS. برای جزئیات، به پیکربندی ACME DNS مراجعه کنید.",
          config: "پیکربندی ACME DNS",
        },
        disableHTTP: "غیرفعال کردن چالش HTTP.",
        disableTLSALPN: "غیرفعال کردن چالش TLS-ALPN.",
        altHTTPPort:
          "پورت جایگزین چالش HTTP. (توجه: اگر می‌خواهید از چیزی غیر از 80 استفاده کنید، باید پورت فوروارد/پروکسی معکوس HTTP از 80 به آن پورت تنظیم کنید، در غیر این صورت ACME نمی‌تواند گواهی صادر کند.)",
        altTLSALPNPort:
          "پورت جایگزین چالش TLS-ALPN. (توجه: اگر می‌خواهید از چیزی غیر از 443 استفاده کنید، باید پورت فوروارد/پروکسی SNI از 443 به آن پورت تنظیم کنید، در غیر این صورت ACME نمی‌تواند گواهی صادر کند.)",
      },
      obfs: {
        type: "نوع",
        salamander: {
          password: "با یک رمز عبور قوی به انتخاب خود جایگزین کنید.",
        },
      },
      quic: {
        initStreamReceiveWindow: "اندازه پنجره دریافت جریان QUIC اولیه.",
        maxStreamReceiveWindow: "حداکثر اندازه پنجره دریافت جریان QUIC.",
        initConnReceiveWindow:
          "اندازه پنجره دریافت اتصال QUIC اولیه.",
        maxConnReceiveWindow:
          "حداکثر اندازه پنجره دریافت اتصال QUIC.",
        maxIdleTimeout:
          "حداکثر زمان بیکاری. مدت زمانی که سرور کلاینت را بدون هیچ فعالیتی همچنان متصل در نظر می‌گیرد.",
        maxIncomingStreams:
          "حداکثر تعداد جریان‌های ورودی همزمان.",
        disablePathMTUDiscovery: "غیرفعال کردن کشف MTU مسیر QUIC.",
      },
      bandwidth: {
        up: "بالا",
        down: "پایین",
      },
      ignoreClientBandwidth:
        "هنگام فعال‌سازی، سرور هرگونه راهنمای پهنای باند تعیین شده توسط کلاینت‌ها را نادیده می‌گیرد",
      congestion: {
        type: "نوع",
        bbrProfile: "این فیلد فقط زمانی اعمال می‌شود که نوع bbr باشد. پیش‌فرض standard است.",
      },
      speedTest:
        "سرعت‌سنج سرور تست سرعت داخلی را فعال می‌کند. هنگامی که فعال باشد، کلاینت‌ها می‌توانند سرعت دانلود و آپلود خود را با سرور آزمایش کنند. برای اطلاعات بیشتر، مستندات Speed Test را ببینید.",
      disableUDP:
        "پروتکل UDP ارسال UDP را غیرفعال می‌کند و فقط اتصالات TCP را مجاز می‌کند.",
      udpIdleTimeout:
        "مدت زمانی که سرور یک پورت UDP محلی را برای هر جلسه UDP بدون فعالیت باز نگه می‌دارد. مشابه مهلت جلسه NAT UDP است.",
      resolver: {
        type: "نوع",
        tcp: {
          addr: "آدرس حل‌کننده TCP.",
          timeout: "مهلت زمانی برای پرس‌وجوهای DNS.",
        },
        udp: {
          addr: "آدرس حل‌کننده UDP.",
          timeout: "مهلت زمانی برای پرس‌وجوهای DNS.",
        },
        tls: {
          addr: "آدرس حل‌کننده TLS.",
          timeout: "مهلت زمانی برای پرس‌وجوهای DNS.",
          sni: "SNI مورد استفاده برای حل‌کننده TLS.",
          insecure: "غیرفعال کردن تأیید TLS برای حل‌کننده TLS.",
        },
        https: {
          addr: "آدرس حل‌کننده HTTPS.",
          timeout: "مهلت زمانی برای پرس‌وجوهای DNS.",
          sni: "SNI مورد استفاده برای حل‌کننده TLS.",
          insecure: "غیرفعال کردن تأیید TLS برای حل‌کننده TLS.",
        },
      },
      sniff: {
        enable: "فعال‌سازی بوییدن پروتکل.",
        timeout:
          "مهلت بوییدن. اگر پروتکل/دامنه در این مدت تعیین نشود، از آدرس اصلی برای برقراری اتصال استفاده می‌شود.",
        rewriteDomain:
          "آیا درخواست‌هایی که آدرس هدف آنها به صورت نام دامنه است بازنویسی شوند. اگر فعال باشد، این درخواست‌ها همچنان بوییده می‌شوند.",
        tcpPorts:
          "لیست پورت‌های TCP. فقط درخواست‌های TCP در این پورت‌ها بوییده می‌شوند.",
        udpPorts:
          "لیست پورت‌های UDP. فقط درخواست‌های UDP در این پورت‌ها بوییده می‌شوند.",
      },
      aclType: "نوع ACL",
      acl: {
        file: "مسیر فایل ACL.",
        inline: "لیست قوانین ACL درون‌خطی.",
        geoip:
          "اختیاری. برای فعال‌سازی، علامت نظر را بردارید. مسیر فایل پایگاه داده GeoIP. اگر حذف شود، Hysteria آخرین پایگاه داده را به‌طور خودکار در پوشه کاری دانلود می‌کند.",
        geosite:
          "اختیاری. برای فعال‌سازی، علامت نظر را بردارید. مسیر فایل پایگاه داده GeoSite. اگر حذف شود، Hysteria آخرین پایگاه داده را به‌طور خودکار در پوشه کاری دانلود می‌کند.",
        geoUpdateInterval:
          "اختیاری. فاصله به‌روزرسانی پایگاه‌های داده GeoIP/GeoSite. پیش‌فرض ۱۶۸ ساعت (۱ هفته). فقط در صورت دانلود خودکار اعمال می‌شود.",
      },
      outbounds: {
        name: "نام خروجی. این در قوانین ACL استفاده می‌شود.",
        type: "نوع",
        socks5: {
          addr: "آدرس پروکسی SOCKS5.",
          username:
            "اختیاری. نام کاربری برای پروکسی SOCKS5، در صورت نیاز به احراز هویت.",
          password:
            "اختیاری. رمز عبور برای پروکسی SOCKS5، در صورت نیاز به احراز هویت.",
        },
        http: {
          url: "آدرس پروکسی HTTP/HTTPS. (می‌تواند http:// یا https:// باشد)",
          insecure:
            "اختیاری. غیرفعال کردن تأیید TLS. فقط برای پروکسی‌های HTTPS اعمال می‌شود.",
        },
        direct: {
          mode: "نوع",
          bindIPv4: "آدرس IPv4 محلی برای اتصال.",
          bindIPv6: "آدرس IPv6 محلی برای اتصال.",
          bindDevice: "رابط شبکه محلی برای اتصال.",
          fastOpen: "فعال‌سازی TCP fast open.",
        },
      },
      trafficStats: {
        listen: "آدرس شنود.",
      },
      masquerade: {
        type: "نوع",
        file: {
          dir: "پوشه برای سرویس‌دهی فایل‌ها.",
        },
        proxy: {
          url: "آدرس وب‌سایت برای پروکسی.",
          rewriteHost:
            "آیا هدر Host برای مطابقت با وب‌سایت پروکسی شده بازنویسی شود. در صورت استفاده سرور وب مقصد از Host برای تعیین سایت ضروری است.",
          insecure: "غیرفعال کردن تأیید TLS برای وب‌سایت پروکسی شده.",
          xForwarded:
            "اختیاری. آیا هدرهای X-Forwarded-For، X-Forwarded-Host و X-Forwarded-Proto هنگام پروکسی تنظیم شوند. پیش‌فرض غیرفعال است.",
        },
        string: {
          content: "متن برای بازگرداندن.",
          headers: "اختیاری. هدرها برای بازگرداندن.",
          statusCode: "اختیاری. کد وضعیت برای بازگرداندن. پیش‌فرض ۲۰۰.",
        },
        listenHTTP: "آدرس شنود HTTP (TCP).",
        listenHTTPS: "آدرس شنود HTTPS (TCP).",
        forceHTTPS:
          "اجباری کردن HTTPS. اگر فعال باشد، تمام درخواست‌های HTTP به HTTPS هدایت می‌شوند.",
      },
    },
  },
};
