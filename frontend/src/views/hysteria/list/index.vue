<template>
  <div class="page-container">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">{{ $t("route.hysteria") }}</h2>
        <p class="page-subtitle">{{ $t("hysteria.subtitle") || "Configure Hysteria2 protocol, transport, and advanced proxy settings" }}</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="submitForm" :icon="Select" size="default">
          {{ $t("common.save") }}
        </el-button>
        <el-upload
          v-model:file-list="fileList"
          :http-request="handleImport"
          :show-file-list="false"
          accept=".yaml"
          :limit="1"
          :before-upload="beforeImport"
        >
          <el-button size="default">
            <template #icon><i-ep-upload /></template>
            {{ $t("common.import") }}
          </el-button>
        </el-upload>
        <el-button @click="handleExport" size="default">
          <template #icon><i-ep-download /></template>
          {{ $t("common.export") }}
        </el-button>
        <el-button @click="handleReset" size="default">
          <template #icon><i-ep-refresh /></template>
          {{ $t("common.reset") }}
        </el-button>
      </div>
    </div>

    <div class="status-bar">
      <div class="status-left">
        <el-switch
          v-model="enableForm.enable"
          active-value="1"
          inactive-value="0"
          @change="handleChangeEnable"
          :active-text="$t('hysteria.enable')"
          :inactive-text="$t('hysteria.disable')"
        />
      </div>
      <div class="status-right">
        <el-tag size="small" :type="hysteria2Monitor.running ? 'success' : 'danger'">
          {{ $t("hysteria.hysteria2Running") }}: {{ hysteria2Monitor.running ? $t("monitor.hysteria2RunningTrue") : $t("monitor.hysteria2RunningFalse") }}
        </el-tag>
        <el-tag size="small" type="info">
          {{ $t("hysteria.hysteria2Version") }}: {{ hysteria2Monitor.version || "-" }}
        </el-tag>
        <el-select
          v-model="hysteria2Version"
          :placeholder="$t('hysteria.hysteria2Version')"
          size="small"
          style="width:140px"
        >
          <el-option v-for="item in hysteria2Versions" :key="item" :label="item" :value="item" />
        </el-select>
        <el-button size="small" type="primary" @click="handleHysteria2ChangeVersion">
          {{ $t("hysteria.hysteria2ChangeVersion") }}
        </el-button>
      </div>
    </div>

    <el-card shadow="never" class="config-card">
      <el-form ref="dataFormRef" :rules="dataFormRules" label-position="top" :model="dataForm">
        <el-tabs v-model="activeName" class="config-tabs" @tab-click="handleTabClick">
          <el-tab-pane :label="$t('hysteria.extension')" name="extension">
            <div class="tab-content">
              <el-row :gutter="24">
                <el-col :span="12">
                  <el-form-item label="remark" prop="remark">
                    <el-input v-model="configForm.remark" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="portHopping" prop="portHopping">
                    <el-input v-model="configForm.portHopping" clearable />
                  </el-form-item>
                </el-col>
              </el-row>
              <el-form-item label="clashExtension" prop="clashExtension">
                <el-input v-model="configForm.clashExtension" type="textarea" :autosize="{ minRows: 3 }" @keydown="(e:KeyboardEvent) => e.stopPropagation()" />
              </el-form-item>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.listen')" name="listen">
            <div class="tab-content">
              <el-form-item label="listen" prop="listen">
                <el-input v-model="dataForm.listen" placeholder=":443" clearable />
              </el-form-item>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.tls')" name="tls">
            <div class="tab-content">
              <el-form-item label="tls.type" prop="tls.type">
                <el-select v-model="tlsType" style="width:100%">
                  <el-option v-for="item in tlsTypes" :key="item" :label="item" :value="item" />
                </el-select>
              </el-form-item>
              <template v-if="tlsType === 'tls'">
                <el-row :gutter="24">
                  <el-col :span="12">
                    <el-form-item label="cert" prop="tls.cert">
                      <div class="input-with-action">
                        <el-input v-model="dataForm.tls.cert" clearable />
                        <el-upload ref="uploadCrtFile" action="" :file-list="crtFileList" :http-request="uploadCertFile" accept=".crt" :before-upload="() => { crtFileList = []; }" :show-file-list="false" :limit="1">
                          <template #trigger><el-button size="small">{{ t("config.uploadCrtFile") }}</el-button></template>
                        </el-upload>
                      </div>
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="key" prop="tls.key">
                      <div class="input-with-action">
                        <el-input v-model="dataForm.tls.key" clearable />
                        <el-upload ref="uploadKeyFile" action="" :file-list="keyFileList" :http-request="uploadCertFile" accept=".key" :before-upload="() => { keyFileList = []; }" :show-file-list="false" :limit="1">
                          <template #trigger><el-button size="small">{{ t("config.uploadKeyFile") }}</el-button></template>
                        </el-upload>
                      </div>
                    </el-form-item>
                  </el-col>
                </el-row>
                <el-form-item label="sniGuard" prop="tls.sniGuard">
                  <el-select v-model="dataForm.tls.sniGuard" style="width:100%" clearable>
                    <el-option v-for="item in tlsSniGuards" :key="item" :label="item" :value="item" />
                  </el-select>
                </el-form-item>
              </template>
              <template v-if="tlsType === 'acme'">
                <el-row :gutter="24">
                  <el-col :span="12">
                    <el-form-item label="acme.domains" prop="acme.domains">
                      <imputMultiple :tags="dataForm.acme.domains" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="acme.email" prop="acme.email">
                      <el-input v-model="dataForm.acme.email" clearable />
                    </el-form-item>
                  </el-col>
                </el-row>
                <el-row :gutter="24">
                  <el-col :span="12">
                    <el-form-item label="acme.ca" prop="acme.ca">
                      <el-select v-model="dataForm.acme.ca" style="width:100%">
                        <el-option v-for="item in acmeCas" :key="item" :label="item" :value="item" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="acme.listenHost" prop="acme.listenHost">
                      <el-input v-model="dataForm.acme.listenHost" clearable />
                    </el-form-item>
                  </el-col>
                </el-row>
                <el-row :gutter="24">
                  <el-col :span="12">
                    <el-form-item label="acme.dir" prop="acme.dir">
                      <el-input v-model="dataForm.acme.dir" clearable />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="acme.type" prop="acme.type">
                      <el-select v-model="dataForm.acme.type" style="width:100%" clearable>
                        <el-option v-for="item in acmeTypes" :key="item" :label="item" :value="item" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                </el-row>
                <template v-if="dataForm.acme.type === 'http'">
                  <el-form-item label="acme.http.altPort" prop="acme.http.altPort">
                    <el-input v-model.number="dataForm.acme.http.altPort" clearable />
                  </el-form-item>
                </template>
                <template v-if="dataForm.acme.type === 'tls'">
                  <el-form-item label="acme.tls.altPort" prop="acme.tls.altPort">
                    <el-input v-model.number="dataForm.acme.tls.altPort" clearable />
                  </el-form-item>
                </template>
                <template v-if="dataForm.acme.type === 'dns'">
                  <el-row :gutter="24">
                    <el-col :span="12">
                      <el-form-item label="acme.dns.name" prop="acme.dns.name">
                        <el-select v-model="dataForm.acme.dns.name" style="width:100%">
                          <el-option v-for="item in dnsNames" :key="item" :label="item" :value="item" />
                        </el-select>
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="acme.dns.config" prop="acme.dns.config">
                        <map-add :map-object="dataForm.acme.dns.config" />
                      </el-form-item>
                    </el-col>
                  </el-row>
                </template>
                <template v-if="!dataForm.acme.type">
                  <el-row :gutter="24">
                    <el-col :span="6">
                      <el-form-item label="acme.disableHTTP" prop="acme.disableHTTP">
                        <el-switch v-model="dataForm.acme.disableHTTP" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="6">
                      <el-form-item label="acme.disableTLSALPN" prop="acme.disableTLSALPN">
                        <el-switch v-model="dataForm.acme.disableTLSALPN" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="6">
                      <el-form-item label="acme.altHTTPPort" prop="acme.altHTTPPort">
                        <el-input v-model.number="dataForm.acme.altHTTPPort" clearable />
                      </el-form-item>
                    </el-col>
                    <el-col :span="6">
                      <el-form-item label="acme.altTLSALPNPort" prop="acme.altTLSALPNPort">
                        <el-input v-model.number="dataForm.acme.altTLSALPNPort" clearable />
                      </el-form-item>
                    </el-col>
                  </el-row>
                </template>
              </template>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.obfs')" name="obfs">
            <div class="tab-content">
              <el-form-item label="obfs.type" prop="obfs.type">
                <el-select v-model="dataForm.obfs.type" style="width:100%" clearable>
                  <el-option v-for="item in obfsTypes" :key="item" :label="item" :value="item" />
                </el-select>
              </el-form-item>
              <template v-if="dataForm.obfs.type === 'salamander'">
                <el-form-item label="obfs.salamander.password" prop="obfs.salamander.password">
                  <el-input v-model="dataForm.obfs.salamander.password" clearable />
                </el-form-item>
              </template>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.quic')" name="quic">
            <div class="tab-content">
              <el-row :gutter="24">
                <el-col :span="12">
                  <el-form-item label="quic.initStreamReceiveWindow" prop="quic.initStreamReceiveWindow">
                    <el-input v-model.number="dataForm.quic.initStreamReceiveWindow" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="quic.maxStreamReceiveWindow" prop="quic.maxStreamReceiveWindow">
                    <el-input v-model.number="dataForm.quic.maxStreamReceiveWindow" clearable />
                  </el-form-item>
                </el-col>
              </el-row>
              <el-row :gutter="24">
                <el-col :span="12">
                  <el-form-item label="quic.initConnReceiveWindow" prop="quic.initConnReceiveWindow">
                    <el-input v-model.number="dataForm.quic.initConnReceiveWindow" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="quic.maxConnReceiveWindow" prop="quic.maxConnReceiveWindow">
                    <el-input v-model.number="dataForm.quic.maxConnReceiveWindow" clearable />
                  </el-form-item>
                </el-col>
              </el-row>
              <el-row :gutter="24">
                <el-col :span="12">
                  <el-form-item label="quic.maxIdleTimeout" prop="quic.maxIdleTimeout">
                    <el-input v-model="dataForm.quic.maxIdleTimeout" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="quic.maxIncomingStreams" prop="quic.maxIncomingStreams">
                    <el-input v-model.number="dataForm.quic.maxIncomingStreams" clearable />
                  </el-form-item>
                </el-col>
              </el-row>
              <el-form-item label="quic.disablePathMTUDiscovery" prop="quic.disablePathMTUDiscovery">
                <el-switch v-model="dataForm.quic.disablePathMTUDiscovery" />
              </el-form-item>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.bandwidth')" name="bandwidth">
            <div class="tab-content">
              <el-row :gutter="24">
                <el-col :span="12">
                  <el-form-item label="bandwidth.up" prop="bandwidth.up">
                    <el-input v-model="dataForm.bandwidth.up" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="bandwidth.down" prop="bandwidth.down">
                    <el-input v-model="dataForm.bandwidth.down" clearable />
                  </el-form-item>
                </el-col>
              </el-row>
              <el-form-item label="ignoreClientBandwidth" prop="ignoreClientBandwidth">
                <el-switch v-model="dataForm.ignoreClientBandwidth" />
              </el-form-item>
              <el-row :gutter="24">
                <el-col :span="12">
                  <el-form-item label="congestion.type" prop="congestion.type">
                    <el-select v-model="dataForm.congestion.type" style="width:100%">
                      <el-option v-for="item in congestionTypes" :key="item" :label="item" :value="item" />
                    </el-select>
                  </el-form-item>
                </el-col>
                <el-col :span="12" v-if="dataForm.congestion.type === 'bbr'">
                  <el-form-item label="congestion.bbrProfile" prop="congestion.bbrProfile">
                    <el-select v-model="dataForm.congestion.bbrProfile" style="width:100%">
                      <el-option v-for="item in bbrProfiles" :key="item" :label="item" :value="item" />
                    </el-select>
                  </el-form-item>
                </el-col>
              </el-row>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.speedTest')" name="speedTest">
            <div class="tab-content">
              <el-form-item label="speedTest" prop="speedTest">
                <el-switch v-model="dataForm.speedTest" />
              </el-form-item>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.udp')" name="udp">
            <div class="tab-content">
              <el-row :gutter="24">
                <el-col :span="12">
                  <el-form-item label="disableUDP" prop="disableUDP">
                    <el-switch v-model="dataForm.disableUDP" />
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="udpIdleTimeout" prop="udpIdleTimeout">
                    <el-input v-model="dataForm.udpIdleTimeout" clearable />
                  </el-form-item>
                </el-col>
              </el-row>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.resolver')" name="resolver">
            <div class="tab-content">
              <el-form-item label="resolver.type" prop="resolver.type">
                <el-select v-model="dataForm.resolver.type" style="width:100%">
                  <el-option v-for="item in resolverTypes" :key="item" :label="item" :value="item" />
                </el-select>
              </el-form-item>
              <template v-if="dataForm.resolver.type === 'tcp'">
                <el-row :gutter="24">
                  <el-col :span="12">
                    <el-form-item label="resolver.tcp.addr" prop="resolver.tcp.addr">
                      <el-input v-model="dataForm.resolver.tcp.addr" clearable />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="resolver.tcp.timeout" prop="resolver.tcp.timeout">
                      <el-input v-model="dataForm.resolver.tcp.timeout" clearable />
                    </el-form-item>
                  </el-col>
                </el-row>
              </template>
              <template v-if="dataForm.resolver.type === 'udp'">
                <el-row :gutter="24">
                  <el-col :span="12">
                    <el-form-item label="resolver.udp.addr" prop="resolver.udp.addr">
                      <el-input v-model="dataForm.resolver.udp.addr" clearable />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="resolver.udp.timeout" prop="resolver.udp.timeout">
                      <el-input v-model="dataForm.resolver.udp.timeout" clearable />
                    </el-form-item>
                  </el-col>
                </el-row>
              </template>
              <template v-if="dataForm.resolver.type === 'tls'">
                <el-row :gutter="24">
                  <el-col :span="8">
                    <el-form-item label="resolver.tls.addr" prop="resolver.tls.addr">
                      <el-input v-model="dataForm.resolver.tls.addr" clearable />
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="resolver.tls.timeout" prop="resolver.tls.timeout">
                      <el-input v-model="dataForm.resolver.tls.timeout" clearable />
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="resolver.tls.sni" prop="resolver.tls.sni">
                      <el-input v-model="dataForm.resolver.tls.sni" clearable />
                    </el-form-item>
                  </el-col>
                </el-row>
                <el-form-item label="resolver.tls.insecure" prop="resolver.tls.insecure">
                  <el-switch v-model="dataForm.resolver.tls.insecure" />
                </el-form-item>
              </template>
              <template v-if="dataForm.resolver.type === 'https'">
                <el-row :gutter="24">
                  <el-col :span="8">
                    <el-form-item label="resolver.https.addr" prop="resolver.https.addr">
                      <el-input v-model="dataForm.resolver.https.addr" clearable />
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="resolver.https.timeout" prop="resolver.https.timeout">
                      <el-input v-model="dataForm.resolver.https.timeout" clearable />
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="resolver.https.sni" prop="resolver.https.sni">
                      <el-input v-model="dataForm.resolver.https.sni" clearable />
                    </el-form-item>
                  </el-col>
                </el-row>
                <el-form-item label="resolver.https.insecure" prop="resolver.https.insecure">
                  <el-switch v-model="dataForm.resolver.https.insecure" />
                </el-form-item>
              </template>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.sniff')" name="sniff">
            <div class="tab-content">
              <el-row :gutter="24">
                <el-col :span="8">
                  <el-form-item label="sniff.enable" prop="sniff.enable">
                    <el-switch v-model="dataForm.sniff.enable" />
                  </el-form-item>
                </el-col>
                <el-col :span="8">
                  <el-form-item label="sniff.timeout" prop="sniff.timeout">
                    <el-input v-model="dataForm.sniff.timeout" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="8">
                  <el-form-item label="sniff.rewriteDomain" prop="sniff.rewriteDomain">
                    <el-switch v-model="dataForm.sniff.rewriteDomain" />
                  </el-form-item>
                </el-col>
              </el-row>
              <el-row :gutter="24">
                <el-col :span="12">
                  <el-form-item label="sniff.tcpPorts" prop="sniff.tcpPorts">
                    <el-input v-model="dataForm.sniff.tcpPorts" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="sniff.udpPorts" prop="sniff.udpPorts">
                    <el-input v-model="dataForm.sniff.udpPorts" clearable />
                  </el-form-item>
                </el-col>
              </el-row>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.acl')" name="acl">
            <div class="tab-content">
              <el-form-item label="acl.type" prop="acl.type">
                <el-select v-model="aclType" style="width:100%" clearable>
                  <el-option v-for="item in aclTypes" :key="item" :label="item" :value="item" />
                </el-select>
              </el-form-item>
              <template v-if="aclType === 'file'">
                <el-form-item label="acl.file" prop="acl.file">
                  <el-input v-model="dataForm.acl.file" clearable />
                </el-form-item>
              </template>
              <template v-if="aclType === 'inline'">
                <el-form-item label="acl.inline" prop="acl.inline">
                  <imputMultiple :tags="dataForm.acl.inline" />
                </el-form-item>
              </template>
              <el-row :gutter="24">
                <el-col :span="8">
                  <el-form-item label="acl.geoip" prop="acl.geoip">
                    <el-input v-model="dataForm.acl.geoip" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="8">
                  <el-form-item label="acl.geosite" prop="acl.geosite">
                    <el-input v-model="dataForm.acl.geosite" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="8">
                  <el-form-item label="acl.geoUpdateInterval" prop="acl.geoUpdateInterval">
                    <el-input v-model="dataForm.acl.geoUpdateInterval" clearable />
                  </el-form-item>
                </el-col>
              </el-row>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.outbounds')" name="outbounds">
            <div class="tab-content">
              <Outbounds :outbounds="dataForm.outbounds" />
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.http')" name="http">
            <div class="tab-content">
              <el-form-item label="trafficStats.listen" prop="trafficStats.listen">
                <el-input v-model="dataForm.trafficStats.listen" clearable />
              </el-form-item>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('hysteria.masquerade')" name="masquerade">
            <div class="tab-content">
              <el-form-item label="masquerade.type" prop="masquerade.type">
                <el-select v-model="dataForm.masquerade.type" style="width:100%" clearable>
                  <el-option v-for="item in masqueradeTypes" :key="item" :label="item" :value="item" />
                </el-select>
              </el-form-item>
              <template v-if="dataForm.masquerade.type === 'file'">
                <el-form-item label="masquerade.file.dir" prop="masquerade.file.dir">
                  <el-input v-model="dataForm.masquerade.file.dir" clearable />
                </el-form-item>
              </template>
              <template v-if="dataForm.masquerade.type === 'proxy'">
                <el-row :gutter="24">
                  <el-col :span="12">
                    <el-form-item label="masquerade.proxy.url" prop="masquerade.proxy.url">
                      <el-input v-model="dataForm.masquerade.proxy.url" clearable />
                    </el-form-item>
                  </el-col>
                  <el-col :span="4">
                    <el-form-item label="masquerade.proxy.rewriteHost" prop="masquerade.proxy.rewriteHost">
                      <el-switch v-model="dataForm.masquerade.proxy.rewriteHost" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="4">
                    <el-form-item label="masquerade.proxy.insecure" prop="masquerade.proxy.insecure">
                      <el-switch v-model="dataForm.masquerade.proxy.insecure" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="4">
                    <el-form-item label="masquerade.proxy.xForwarded" prop="masquerade.proxy.xForwarded">
                      <el-switch v-model="dataForm.masquerade.proxy.xForwarded" />
                    </el-form-item>
                  </el-col>
                </el-row>
              </template>
              <template v-if="dataForm.masquerade.type === 'string'">
                <el-row :gutter="24">
                  <el-col :span="12">
                    <el-form-item label="masquerade.string.content" prop="masquerade.string.content">
                      <el-input v-model="dataForm.masquerade.string.content" clearable />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="masquerade.string.statusCode" prop="masquerade.string.statusCode">
                      <el-input v-model.number="dataForm.masquerade.string.statusCode" clearable />
                    </el-form-item>
                  </el-col>
                </el-row>
                <el-form-item label="masquerade.string.headers" prop="masquerade.string.headers">
                  <map-add :map-object="dataForm.masquerade.string.headers" />
                </el-form-item>
              </template>
              <el-row :gutter="24">
                <el-col :span="8">
                  <el-form-item label="masquerade.listenHTTP" prop="masquerade.listenHTTP">
                    <el-input v-model="dataForm.masquerade.listenHTTP" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="8">
                  <el-form-item label="masquerade.listenHTTPS" prop="masquerade.listenHTTPS">
                    <el-input v-model="dataForm.masquerade.listenHTTPS" clearable />
                  </el-form-item>
                </el-col>
                <el-col :span="8">
                  <el-form-item label="masquerade.forceHTTPS" prop="masquerade.forceHTTPS">
                    <el-switch v-model="dataForm.masquerade.forceHTTPS" />
                  </el-form-item>
                </el-col>
              </el-row>
            </div>
          </el-tab-pane>
        </el-tabs>
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
import {
  ConfigsUpdateDto,
  defaultHysteria2ServerConfig,
  Hysteria2ServerConfig,
} from "@/api/config/types";
import Outbounds from "./components/Outbounds/index.vue";
import { Select } from "@element-plus/icons-vue";
import {
  exportHysteria2ConfigApi,
  getHysteria2ConfigApi,
  importHysteria2ConfigApi,
  listConfigApi,
  updateConfigsApi,
  updateHysteria2ConfigApi,
  uploadCertFileApi,
} from "@/api/config";
import { useI18n } from "vue-i18n";
import { assignWith, deepCopy } from "@/utils/copy";
import {
  UploadFile,
  UploadRawFile,
  UploadRequestOptions,
} from "element-plus/lib/components";
import { hysteria2ChangeVersionApi, listReleaseApi } from "@/api/hysteria2";
import { monitorHysteria2Api } from "@/api/monitor";
import { UploadUserFile } from "element-plus";

const { t } = useI18n();

const hysteria2EnableKey = "HYSTERIA2_ENABLE";
const hysteria2Remark = "HYSTERIA2_CONFIG_REMARK";
const hysteria2ConfigPortHopping = "HYSTERIA2_CONFIG_PORT_HOPPING";
const clashExtension = "CLASH_EXTENSION";
const dataFormRef = ref(ElForm);

const dataFormRules = {
  listen: [
    { required: true, message: "Required", trigger: ["change", "blur"] },
  ],
  "trafficStats.listen": [
    { required: true, message: "Required", trigger: ["change", "blur"] },
  ],
};

const tlsTypes = ref<string[]>(["tls", "acme"]);
const congestionTypes = ref<string[]>(["bbr", "reno"]);
const bbrProfiles = ref<string[]>(["standard", "conservative", "aggressive"]);
const tlsSniGuards = ref<string[]>(["dns-san", "disable", "strict"]);
const aclTypes = ref<string[]>(["file", "inline"]);
const acmeCas = ref<string[]>(["zerossl", "letsencrypt"]);
const acmeTypes = ref<string[]>(["http", "tls", "dns"]);
const dnsNames = ref<string[]>([
  "cloudflare", "duckdns", "gandi", "godaddy", "namedotcom", "vultr",
]);
const obfsTypes = ref<string[]>(["salamander"]);
const resolverTypes = ref<string[]>(["tcp", "udp", "tls", "https"]);
const masqueradeTypes = ref<string[]>(["file", "proxy", "string"]);

const state = reactive({
  enableForm: { enable: "0" },
  configForm: { remark: "", portHopping: "", clashExtension: "" },
  dataForm: { ...defaultHysteria2ServerConfig } as Hysteria2ServerConfig,
  activeName: "extension",
  tlsType: "acme",
  aclType: "inline",
  fileList: [] as UploadFile[],
  hysteria2Version: "",
  hysteria2Versions: [] as string[],
  hysteria2Monitor: { version: "", running: false },
  crtFileList: [] as UploadUserFile[],
  keyFileList: [] as UploadUserFile[],
});

const {
  enableForm, configForm, activeName, dataForm, tlsType, aclType,
  fileList, hysteria2Version, hysteria2Versions, hysteria2Monitor,
  crtFileList, keyFileList,
} = toRefs(state);

const handleTabClick = () => {};

const handleImport = (params: UploadRequestOptions) => {
  if (state.fileList.length > 0) {
    let formData = new FormData();
    formData.append("file", params.file);
    importHysteria2ConfigApi(formData).then(() => {
      ElMessage.success(t("common.success"));
    });
    state.fileList = [];
  }
};

const beforeImport = (file: UploadRawFile) => {
  if (!file.name.endsWith(".yaml")) {
    ElMessage.error("file format not supported");
    return false;
  }
  if (file.size / 1024 / 1024 > 2) {
    ElMessage.error("the file is too big, less than 2 MB");
    return false;
  }
};

const handleExport = async () => {
  let response = await exportHysteria2ConfigApi();
  try {
    const blob = new Blob([response.data], { type: "application/octet-stream" });
    let url = window.URL.createObjectURL(blob);
    let a = document.createElement("a");
    document.body.appendChild(a);
    a.href = url;
    let dis = response.headers["content-disposition"];
    a.download = dis.split("attachment; filename=")[1];
    a.click();
    window.URL.revokeObjectURL(url);
    ElMessage.success(t("common.success"));
  } catch (e) {}
};

const handleReset = () => {
  state.configForm = { remark: "", portHopping: "", clashExtension: "" };
  state.dataForm = deepCopy(defaultHysteria2ServerConfig);
  state.activeName = "extension";
  state.tlsType = "acme";
  state.aclType = "inline";
  state.fileList = [];
};

const handleChangeEnable = async () => {
  const enable = state.enableForm.enable === "1" ? "0" : "1";
  try {
    await updateConfigsApi({
      configUpdateDtos: [
        { key: hysteria2EnableKey, value: state.enableForm.enable },
      ],
    });
    if (state.enableForm.enable === "1") {
      ElMessage.success(t("common.enableSuccess"));
    } else {
      ElMessage.error(t("common.disableSuccess"));
    }
  } catch (e) {
    state.enableForm.enable = enable;
  }
  await setHysteria2Monitor();
};

const submitForm = () => {
  dataFormRef.value.validate((valid: any) => {
    if (valid) {
      let configs: ConfigsUpdateDto[] = [
        { key: hysteria2Remark, value: state.configForm.remark },
        { key: hysteria2ConfigPortHopping, value: state.configForm.portHopping },
        { key: clashExtension, value: state.configForm.clashExtension },
      ];
      updateConfigsApi({ configUpdateDtos: configs });

      if (state.tlsType == "tls") {
        state.dataForm.acme = undefined;
      } else if (state.tlsType == "acme") {
        state.dataForm.tls = undefined;
        if (state.dataForm.acme?.type == "http") {
          state.dataForm.acme.tls = undefined;
          state.dataForm.acme.dns = undefined;
        } else if (state.dataForm.acme?.type == "tls") {
          state.dataForm.acme.http = undefined;
          state.dataForm.acme.dns = undefined;
        } else if (state.dataForm.acme?.type == "dns") {
          state.dataForm.acme.http = undefined;
          state.dataForm.acme.tls = undefined;
        } else if (state.dataForm.acme?.type == "") {
          state.dataForm.acme.http = undefined;
          state.dataForm.acme.tls = undefined;
          state.dataForm.acme.dns = undefined;
        }
      }

      if (state.dataForm.acl) {
        if (state.aclType == "inline") state.dataForm.acl.file = undefined;
        else if (state.aclType == "file") state.dataForm.acl.inline = undefined;
      }

      if (state.dataForm.resolver?.type == "tcp") {
        state.dataForm.resolver.udp = undefined;
        state.dataForm.resolver.tls = undefined;
        state.dataForm.resolver.https = undefined;
      } else if (state.dataForm.resolver?.type == "udp") {
        state.dataForm.resolver.tcp = undefined;
        state.dataForm.resolver.tls = undefined;
        state.dataForm.resolver.https = undefined;
      } else if (state.dataForm.resolver?.type == "tls") {
        state.dataForm.resolver.tcp = undefined;
        state.dataForm.resolver.udp = undefined;
        state.dataForm.resolver.https = undefined;
      } else if (state.dataForm.resolver?.type == "https") {
        state.dataForm.resolver.tcp = undefined;
        state.dataForm.resolver.udp = undefined;
        state.dataForm.resolver.tls = undefined;
      }

      if (state.dataForm.masquerade?.type == "file") {
        state.dataForm.masquerade.proxy = undefined;
        state.dataForm.masquerade.string = undefined;
      } else if (state.dataForm.masquerade?.type == "proxy") {
        state.dataForm.masquerade.file = undefined;
        state.dataForm.masquerade.string = undefined;
      } else if (state.dataForm.masquerade?.type == "string") {
        state.dataForm.masquerade.file = undefined;
        state.dataForm.masquerade.proxy = undefined;
      }

      if (!state.dataForm.obfs?.type) state.dataForm.obfs = undefined;
      if (!state.dataForm.quic) state.dataForm.quic = undefined;
      if (!state.dataForm.bandwidth) {
        state.dataForm.bandwidth = undefined;
        state.dataForm.ignoreClientBandwidth = undefined;
        state.dataForm.congestion = undefined;
      }
      if (!state.dataForm.speedTest) state.dataForm.speedTest = undefined;
      if (!state.dataForm.disableUDP && !state.dataForm.udpIdleTimeout) {
        state.dataForm.disableUDP = undefined;
        state.dataForm.udpIdleTimeout = undefined;
      }
      if (!state.dataForm.resolver?.type) state.dataForm.resolver = undefined;
      if (!state.dataForm.sniff) state.dataForm.sniff = undefined;
      if (!state.dataForm.acl?.file && !state.dataForm.acl?.inline && !state.dataForm.acl?.geoip) state.dataForm.acl = undefined;
      if (!state.dataForm.outbounds?.length) state.dataForm.outbounds = undefined;
      if (!state.dataForm.masquerade?.type) state.dataForm.masquerade = undefined;

      if (state.dataForm?.udpIdleTimeout === "") state.dataForm.udpIdleTimeout = "60s";
      if (state.dataForm?.quic?.maxIdleTimeout === "") state.dataForm.quic.maxIdleTimeout = "30s";
      if (state.dataForm?.resolver?.tcp?.timeout === "") state.dataForm.resolver.tcp.timeout = "4s";
      if (state.dataForm?.resolver?.udp?.timeout === "") state.dataForm.resolver.udp.timeout = "4s";
      if (state.dataForm?.resolver?.tls?.timeout === "") state.dataForm.resolver.tls.timeout = "10s";
      if (state.dataForm?.resolver?.https?.timeout === "") state.dataForm.resolver.https.timeout = "10s";
      if (state.dataForm?.sniff?.timeout === "") state.dataForm.sniff.timeout = "2s";
      if (state.dataForm?.acl?.geoUpdateInterval === "") state.dataForm.acl.geoUpdateInterval = "168h";

      const params = { ...state.dataForm };
      updateHysteria2ConfigApi(params).then(() => {
        ElMessage.success(t("common.success"));
        setConfig();
      });
    }
  });
};

const setConfig = () => {
  listConfigApi({
    keys: [hysteria2EnableKey, hysteria2Remark, hysteria2ConfigPortHopping, clashExtension],
  }).then((response) => {
    const data = response.data;
    data.forEach((configVo) => {
      if (configVo.key === hysteria2EnableKey) state.enableForm.enable = configVo.value;
      else if (configVo.key === hysteria2Remark) state.configForm.remark = configVo.value;
      else if (configVo.key === hysteria2ConfigPortHopping) state.configForm.portHopping = configVo.value;
      else if (configVo.key === clashExtension) state.configForm.clashExtension = configVo.value;
    });
  });

  getHysteria2ConfigApi().then((response) => {
    const data = response.data;
    if (data) {
      state.tlsType = data?.tls?.cert && data?.tls?.key ? "tls" : "acme";
      state.aclType = data?.acl?.inline ? "inline" : "file";
      state.dataForm = deepCopy(defaultHysteria2ServerConfig);
      assignWith(state.dataForm, data);
    }
  });
};

const setHysteria2Versions = async () => {
  const { data } = await listReleaseApi();
  state.hysteria2Versions = data;
};

const setHysteria2Monitor = async () => {
  const { data } = await monitorHysteria2Api();
  Object.assign(state.hysteria2Monitor, data);
};

const handleHysteria2ChangeVersion = async () => {
  if (!state.hysteria2Version) {
    ElMessage.error("version number is required");
    return;
  }
  ElMessage.info(t("common.wait"));
  await hysteria2ChangeVersionApi({ version: state.hysteria2Version });
  ElMessage.success(t("common.success"));
  await setHysteria2Monitor();
};

const uploadCertFile = async (params: UploadRequestOptions) => {
  try {
    if (!state.dataForm.tls) return;
    if (!params.file.name.endsWith(".crt") && !params.file.name.endsWith(".key")) {
      ElMessage.error("file format not supported");
    }
    if (params.file.size > 1024 * 1024) {
      ElMessage.error("the file is too big");
    }
    let formData = new FormData();
    formData.append("file", params.file);
    const { data } = await uploadCertFileApi(formData);
    if (params.file.name.endsWith(".crt")) state.dataForm.tls.cert = data;
    else if (params.file.name.endsWith(".key")) state.dataForm.tls.key = data;
  } catch (e) {}
};

onMounted(() => {
  setConfig();
  setHysteria2Versions();
  setHysteria2Monitor();
});
</script>

<style lang="scss" scoped>
.page-container {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 20px;
  .header-left {
    .page-title { margin: 0 0 6px; font-size: 22px; font-weight: 700; color: var(--el-text-color-primary); letter-spacing: -0.3px; }
    .page-subtitle { margin: 0; font-size: 13px; color: var(--el-text-color-secondary); line-height: 1.4; }
  }
  .header-actions { display: flex; gap: 8px; flex-shrink: 0; flex-wrap: wrap; }
}

.status-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  background: var(--el-bg-color-overlay);
  border: 1px solid var(--el-border-color-light);
  border-radius: 12px;
  margin-bottom: 20px;
  .status-left { display: flex; align-items: center; gap: 12px; }
  .status-right { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
}

.config-card {
  border-radius: 14px;
  :deep(.el-card__body) { padding: 0; }
}

.config-tabs {
  :deep(.el-tabs__header) {
    margin: 0;
    padding: 0 20px;
    background: var(--el-fill-color-lighter);
    border-radius: 14px 14px 0 0;
    border-bottom: 1px solid var(--el-border-color-light);
  }
  :deep(.el-tabs__nav-wrap) { margin-bottom: 0; }
  :deep(.el-tabs__active-bar) { height: 3px; border-radius: 3px 3px 0 0; }
  :deep(.el-tabs__item) {
    font-size: 13px;
    font-weight: 500;
    padding: 0 16px;
    height: 42px;
    line-height: 42px;
    transition: color 0.2s, background 0.2s;
    &:hover { color: var(--el-color-primary); }
    &.is-active { font-weight: 600; color: var(--el-color-primary); background: var(--el-bg-color); }
  }
}

.tab-content {
  padding: 24px;
  :deep(.el-form-item) { margin-bottom: 20px; }
  :deep(.el-form-item__label) {
    font-size: 13px;
    font-weight: 600;
    color: var(--el-text-color-secondary);
    padding-bottom: 4px;
  }
  :deep(.el-switch) { height: 24px; }
}

.input-with-action {
  display: flex;
  gap: 8px;
  align-items: center;
  .el-input { flex: 1; }
}

@media (max-width: 900px) {
  .page-container { padding: 16px; }
  .page-header { flex-direction: column; align-items: flex-start; gap: 16px; }
  .status-bar { flex-direction: column; align-items: flex-start; gap: 12px; .status-right { width: 100%; } }
  .tab-content { padding: 16px; }
}
</style>
