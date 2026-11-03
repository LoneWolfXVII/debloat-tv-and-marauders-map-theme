# TCL/Huan network updater protocol (com.tcl.versionUpdateApp) on the Micromax T658TAP set

Analysed 2026-11-04, offline only. No request was sent to any TCL/Huan host and the TV was not touched. Confidence tags follow `firmware_T658TAP.md`: **[V]** seen in the local data (logcat, manifest, resources, getprop), **[I]** my inference, **[?]** unknown until the code is decompiled.

Inputs: `~/tv-backup/2026-11-03_2334-MICROMAX_TV/` (`ota_logcat.txt`, `getprop.txt`, `dumpsys_package.txt`, `apks/`).
Scratch decompile output: `/private/tmp/claude-501/-Users-nischalgupta-Documents-PROJECTS-personal/b6393fc4-b2f4-4dba-a151-f939d13142c8/scratchpad/updater/{vu,da,ss}` (jadx 1.5.6, installed with brew).

## 0. Main limitation: the backed-up APKs contain no code

- `versionUpdate.apk` and `TCL_common_DeviceAuthention.apk` (StartandroidService) are **pre-optimised system APKs**. They hold only `AndroidManifest.xml`, `resources.arsc`, `res/` and `META-INF/`. There is no `classes.dex`. jadx gives back only `R.java`. [V]
- 109 of the 161 backed-up APKs are the same. `SystemSettings.apk` (com.tcl.settings) does have dex, but it only contains the DVB-SSU/OTA interfaces (`com.tcl.ssu.*`) and none of the Huan client. [V]
- The code is on the TV at `/system/priv-app/versionUpdate/oat/arm/versionUpdate.{odex,vdex}`. dumpsys reports `status=kOatUpToDate, compilation_filter=quicken`, so the full dex is inside the `.vdex`. [V]
- No dex in the backup contains the strings `upgradeIncr`, `networkupgrade`, `upmp`, `huan.tv` (apart from an EPG host `ausepg.huan.tv` in TIF_LiveTV), `cedock` or `Update.pkg`. [V]

Everything below is therefore taken from the **logcat** (which prints the full request XML), the **manifest** and the **string resources**. These are not code excerpts, because no code is available. Section 7 lists the one read-only pull that would let every [?] be answered.

## 1. Request

### Endpoint and transport
| Item | Value | Source |
|---|---|---|
| URL | `http://as.api.upgrade.platform.huan.tv/service/upmp/upgradeIncrInterface` | [V] `ProtocolAddrChanger` / `UpDevice` / `HttpPipe` log lines |
| Scheme | plain HTTP, port 80 (no TLS) | [V] URL; `Connect to /20.24.130.41:80 timed out` |
| Resolved IP (on the TV, 2026-11-04) | `20.24.130.41` | [V] ConnectTimeoutException in the first auto-check |
| Client library | Apache HttpClient (`AbstractHttpClient.execute`) called from `com.tcl.networkupgrade.net.HttpPipe.forConnection(HttpPipe.java:56)` | [V] stack trace |
| Method | POST with an XML entity | [I, strong] An XML body is built and sent, and Apache's `HttpGet` cannot carry an entity. The method itself is not logged. |
| Headers (Content-Type, User-Agent, any auth) | not logged | [?] |
| Timeout | about 10 s connect timeout, then retry | [I] first attempt at 00:11:21 timed out, retry at 00:11:31 succeeded |

Call chain seen in the stack traces and log tags [V]:
```
com.tcl.systemupdate.NetworkUpgrade$3.run (NetworkUpgrade.java:209)
 -> NetworkUpgrade.checkUpdate (NetworkUpgrade.java:281)
 -> com.tcl.networkupgrade.check.UpdateCheck.sendUpdateCheck (UpdateCheck.java:77)
 -> UpdateCheck.obtainUpdateInfo (UpdateCheck.java:120)
     -> UpDevice.getRealDeviceInfo  (language, timezone, country, projectId, clientType)
     -> ProtocolAddrChanger           (zone -> server URL; checks persist.sys.tcl.fota)
     -> SenderAndReceiver             (builds request XML, parses response)
 -> com.tcl.networkupgrade.net.HttpPipe.forConnection (HttpPipe.java:56)
Also: com.tcl.networkupgrade.reportVersion.ReportUpdateMessage / ReportUtil (separate "report to server" thread)
      OperateUtils.getUpdateStatus  -> reads /cache/recovery/last_update_file
```
Two callers start a check: `service.AutoUpdateService`, at boot and in the background (pid 2469 at 00:11), and `UI.SystemUpdateActivity` > Network update, through `NetworkUpgrade.startManualCheck` (pid 4918 at 00:12:58). [V]

### Request body exactly as logged (`SenderAndReceiver`, "upGrade请求")
```xml
<?xml version="1.0" encoding="UTF-8"?>
<upgradeIncrRequest>
<upmptype>3</upmptype>
<parameter>
<callid>0</callid>
<language>en_IN</language>
<timezone>+0800</timezone>
<region>IN</region>
<client>
<dnum><dnum></dnum>
<didtoken><didtoken></didtoken>
<devmodel>SCBC-AP-MT5658-0000A</devmodel>
<projectid>207</projectid>
<systemver>8.0.0</systemver>
</client>
</parameter>
<app>
<appid>V8T658TAP</appid>
<ver>V8-T658TAP-LF1V372</ver>
<verid>0</verid>
</app>
<apiversion>"1.0"</apiversion>
</upgradeIncrRequest>
```
The real `dnum` (9 digits) and `didtoken` (32 hex characters) are in `ota_logcat.txt` around line 129. They are device identifiers, so they are kept out of this note.

### Where each field comes from (values for THIS TV)
| Field | This TV | Source | Conf. |
|---|---|---|---|
| `upmptype` | `3` | Constant in the client. Probably the platform or terminal type. | [V] value, [?] meaning |
| `callid` | `0` | Constant on the request. The server returns its own callid. | [V] |
| `language` | `en_IN` | System locale (`persist.sys.locale=en-IN`, rewritten as `ll_CC`). Logged by `UpDevice` as "language en_IN". | [V] |
| `timezone` | `+0800` | Logged by `UpDevice` as "timezoneValue +0800". **This does not match** `persist.sys.timezone=GMT+05:30`. It is either hard-coded or read from TCL's own time setting (the build is CST/+0800). | [V] value, [?] source |
| `region` | `IN` | Locale country. Logged by `UpDevice` as "country IN". | [V] |
| `dnum` | `<dnum>` (9 digits) | Huan device number. Almost certainly issued by Huan device registration in `com.tcl.xian.StartandroidService` (TCL_common_DeviceAuthention, which exports `MyContentProvider` and has Huan-account strings) and read from there. Not in getprop. | [I] |
| `didtoken` | `<didtoken>` (32 hex) | Huan device token, same source as `dnum`. Not in getprop, and the server may check it. | [I] |
| `devmodel` | `SCBC-AP-MT5658-0000A` | TCL "client type". `DeviceInfoImpl.getClientType()` in system_server (`TVKitService`, library `com.tcl.deviceinfo`). Not a getprop value. Probably from TCL's NVM or project config. | [V] value, [I] storage |
| `projectid` | `207` | `DeviceInfoImpl.getProjectID()`, logged as "getProjectID from map is 207", so it comes from a project-index-to-ID map in TCL's config. Not in getprop. | [V] |
| `systemver` | `8.0.0` | `ro.build.version.release` | [V] |
| `appid` | `V8T658TAP` | `ro.software.version_id` (`V8-T658TAP-LF1V372`) with `-LF1Vnnn` removed and the dash taken out. | [V] value, [I] derivation |
| `ver` | `V8-T658TAP-LF1V372` | `ro.software.version_id` | [V] |
| `verid` | `0` | Unknown. Possibly a numeric version id or the last incremental step. | [?] |
| `apiversion` | `"1.0"` (quote marks included literally) | Constant. The literal quotes look like a client bug. | [V] |

Values that need data we do not have:
- `dnum` and `didtoken`. We have the logged copies, but their origin (StartandroidService's provider or database under `/data/data/com.tcl.xian.StartandroidService/`) is root-only. It is also unknown whether `didtoken` rotates.
- The NVM/config entries behind `getClientType`/`getProjectID`. The logged values are enough to replay the request.
- The HTTP headers.

### Region to domain
- `UpDevice` logs "clientType = SCBC-AP-MT5658-0000A" and then "zone = AP". `ProtocolAddrChanger` logs "zone = AP", then "serverUrl = http://as.api.upgrade.platform.huan.tv/...". So the **zone is the second dash-separated field of the client type**, and `AP` maps to the `as.` host. [V]
- `ProtocolAddrChanger` also logs "persist.sys.tcl.fota is null or true". That property is not set on this TV. When it is `false`, a different (older or non-FOTA) address is probably used. [V log, ? effect]
- Hosts for other zones (`eu.` / `na.` / `la.` etc. `api.upgrade.platform.huan.tv`) are **not visible** in the data. By analogy with TCL's CDN (`eu-`/`na-`/`as-update.cedock.com`, see `firmware_T658TAP.md`) they probably exist. [I]
- Endpoint names: only **`upgradeIncrInterface`** has been seen. Whether the code also holds a full, forced or recovery variant (for example an `upgradeInterface`) is [?] until decompiled. Nothing in the resources names one.

## 2. Response

### What the server actually returned (three checks, 00:11:31 and 00:13:03)
```xml
<upgradeIncrResponse>
    <servertime>1746500000</servertime>
    <callid>637e5717b02f69d3d3788f915da171b3</callid>
    <state>0000</state>
    <note>成功</note>          <!-- "success" -->
    <language>en_US</language>
    <apiversion>1.0</apiversion>
</upgradeIncrResponse>
```
- HTTP 200, and `state 0000` means success. There is **no `<app>`/package element**, so no update is offered. [V]
- **This looks like a static stub, not a live server** [I, strong]:
  - `servertime` is the round number 1746500000 (2025-05-06 02:53:20 UTC) on a check made in Nov 2026.
  - `callid` is identical on both checks, 92 s apart.
  - It answers `en_US` although the request said `en_IN`.
  - It resolves to a 20.x address that first refused to connect.
  - The likely meaning is that Huan/TCL now park this endpoint with a "nothing for you" reply.
- **The client also rejects the reply.** `SenderAndReceiver` logs "error response :not starts with <?xml". The parser requires the body to start with an XML prolog, and this stub does not have one. As a result `UpdateCheck.sendResult=false`, then `NetworkUpgrade msg.what=601`, then `NUListener -5 ERROR_NETWORK_ERROR`, then UI code 9041, "Cannot access network resources...". This is why the TV shows a network error instead of "No need to update". [V]

### Fields that carry the package (download URL, size, MD5, version, type)
- Not observable, because no package was ever returned and the parser is in the missing dex. [?]
- What the resources and the SSU interface tell us [I]:
  - **MD5 is checked** after a network download (`MD5Verify_Failed`: "Validation of update package failed..."). So the response carries an MD5.
  - **Size** is checked against free space (`Dialog_NoSpace`), so the response carries a size. The shared SSU interface keys are `TargetFileSize`, `TargetSoftwareVersion`, `UpgradeDescription`, `UpgradeFileType`, `UpgradeType`, `DownloadedFilePath` and `DownloadPercent` (`com.tcl.ssu.SSU`, in SystemSettings.apk). These are the client-side names the updater exposes and probably mirror the response fields.
  - **Download host:** probably TCL's CDN `as-update.cedock.com/apps/resource2/V8T658TAP/V8-T658TAP-LF1Vnnn/...` (pattern from `firmware_T658TAP.md`).
  - **Release-notes text:** shown in the "New update package X is located, download and update now?" dialog.

## 3. Full package versus incremental

- The interface name is **"Incr"**, meaning incremental. The request has **no field that obviously asks for a full package**. The only candidate is `verid`, which may tell the server which incremental base the TV is on. [V/I]
- The UI does know two package types:
  - Strings `netUpdate_downloading` = "Update Package ..." and `netUpdate_Part` = "Patch Package". [V]
  - String `Dialog_SelectDownloadType` = "Please select update package type." [V]
  - Receiver `.broadcastManage.UpdatePackageTypeReceiver` on action `com.tcl.versionUpdateApp.action.updatePackageType`. [V]
- **Best reading [I]:** the server can return more than one package (full and patch) in a single `upgradeIncrResponse`, and the user or client picks one. The choice is made **client-side from the response, not by a request parameter**. A different `upmptype` or `ver`/`verid` might change what the server offers, but only the decompiled `SenderAndReceiver`/`UpdateCheck` can confirm that. [?]
- The current stub returns nothing for our `ver`, so this question only matters if a live endpoint exists somewhere.

## 4. Local update (USB)

From the strings, the manifest and the logs [V]:
- Entry point: `SystemUpdateActivity` > "Local update" (layout id `localupdate`). The flow is `UpdateCheck` with `LocalUpdateCheck` (logged as "LocalUpdateCheck-----------").
- The `BroadCastManger` receiver watches `MEDIA_MOUNTED`/`UNMOUNTED`/`REMOVED`/`EJECT`, so the updater scans newly mounted USB volumes.
- Messages and checks, in order:
  1. "local detecting..."
  2. "New upgrade file found, verifying..." (`LocalUpdate_Verify_Progress`)
  3. Possible failures:
     - "The validation of update package failed" (`Dialog_VerifyFailed_Local`). An integrity or signature check exists.
     - "The local hardware version does not match update file" (`Dialog_HardWareUnequal_Local`). The package header carries a hardware id that is compared with the TV's, probably `ro.hardware.version_id=MT5658` or the client type or project ID.
     - "Failed to get info from update file" (`Dialog_IOException_Local`). The client reads a header or info block from the file.
     - "Please check the update folder permission" (`Dialog_NoRight_Local`).
  4. **"The version of new update package is lower than that of TV system. Do you want to update?"** (`Dialog_LocalVersion_Higher`). **A downgrade is allowed after confirmation.**
  5. "Click OK, the TV will restart and start upgrading" (`Dialog_PackExits_Local`). The app reboots into the bootloader or recovery updater. It holds `REBOOT` and `ACCESS_CACHE_FILESYSTEM`, and `OperateUtils.getUpdateStatus` reads `/cache/recovery/last_update_file` after the reboot.
- **Network downloads also go to USB.** Examples: "New update package is located, please insert USB drive" and "No storage device located for auto update, please insert storage device". [V] So the network flow saves the same kind of file the USB flow uses onto a USB stick, then reboots to flash it. [I] If the server ever offered a package, a copy would end up on the stick.
- **Expected file name and path** (`Update.pkg`? `*_sign.pkg`? `*.zip`? root or a folder?): **not in the resources**, so it is a constant in the missing dex. [?] Community knowledge for T658 (see `firmware_T658TAP.md` Q4) is a `.pkg` at the USB root for the power-key path. The scan behind the Settings "Local update" menu may differ.
- **Verification method** (MD5 against a header, RSA signature, or both): [?] needs code. The strings only prove that verification and a hardware check exist.

## 5. getprop values used, for this TV

| Property | Value | Used for |
|---|---|---|
| `ro.software.version_id` | `V8-T658TAP-LF1V372` | `ver`, and `appid` = `V8T658TAP` |
| `ro.build.version.release` | `8.0.0` | `systemver` |
| `persist.sys.locale` | `en-IN` | `language`=`en_IN`, `region`=`IN` |
| `persist.sys.timezone` | `GMT+05:30` | **not** what is sent (`+0800` is sent) |
| `ro.hardware.version_id` | `MT5658` | probably the local-update hardware check [I] |
| `persist.sys.tcl.fota` | (unset) | `ProtocolAddrChanger` treats unset as true, which selects the FOTA URL |
| `ro.sita.model.SystemUpdate.RestoreFactory` | (unset, so false) | hides Restore Factory in the updater UI |
| `ro.mtk.system.marketregion` | `eu` | not used in the request (the zone comes from the client type) |
| `sys.updateDownLoading` | `false` | the updater's "download in progress" flag |

Values that are not in getprop are `dnum`, `didtoken`, `devmodel`/client type and `projectid`. They come from system_server (`DeviceInfoImpl`) and from StartandroidService. The logged values are enough, and their backing stores are root-only.

## 6. Risks

- **Silent or forced updates.**
  - `AutoUpdateService` checks on `BOOT_COMPLETED`, after STR (quick-start) resume, and in the background.
  - Strings show an auto-download path ("Update package for auto update downloaded successfully, the TV will restart later!") and a forced path ("New update package found, system is processing").
  - If the endpoint ever returned a package marked forced or auto, the TV could download it and reboot into the flasher without asking.
  - This does not matter for an offline replay from a PC, but the TV must not be on a network where someone can answer that host (the protocol is plain HTTP, so it can be spoofed).
- **No TLS and an unauthenticated response.** Any machine on the path could serve a crafted response. Only the client-side MD5 and the package signature check protect the TV.
- **Device identifiers in the request** (`dnum`, `didtoken`, client type, project ID). Replaying the request from a PC hands those to Huan/TCL and ties the query to this TV.
- **Downgrade is allowed** in the local-update UI after one confirmation. A wrong or older package could be flashed. See the Project ID / panel whitelist risk in `firmware_T658TAP.md`.
- **The live server looks like a stub** (section 2). A replay will most likely return the same empty `0000` reply whatever is sent. Low expected value.

## 7. Next step to close every [?] (needs the TV, read-only, user approval)

```
adb pull /system/priv-app/versionUpdate/oat/arm/versionUpdate.vdex
adb pull /system/priv-app/TCL_common_DeviceAuthention/oat/arm/TCL_common_DeviceAuthention.vdex
# shell user can read /system; no root needed
```
Then, offline:
1. Run `vdexExtractor -i versionUpdate.vdex -o out/`. It handles Android 8.0 vdex v006 and un-quickens the code. The result is `versionUpdate_classes.dex`.
2. Decompile it with `jadx -d vu_code out/*.dex`.
3. Grep for `upgradeIncr`, `Interface"`, `upmptype`, `.pkg`, `.zip`, `md5`, `<url>`, `force`, `incr`, `full`, `verid`.

The classes to read are:
- `SenderAndReceiver`: request and response schema.
- `ProtocolAddrChanger`: zone-to-host table.
- `UpDevice`: field sources.
- `UpdateCheck` / `LocalUpdateCheck`: file names and verification.
- `UpdateDownload`: download and MD5.
- The `com.tcl.networkupgrade.reportVersion` classes.
