# 本轮验证记录

日期：2026-10-10。基线：2cf91deeec36310ff1b05d0a9039519179d5534b；分支 personal/viewer-file-drag；版本 10.0.6.906。

## 实现范围

拖放功能只改上游 ViewerControl.cs 的 10 行，并新增 103 行 ViewerControl_FileDrag.cs。Core.cs 另有自用 Pro 单行开关，独立补丁维护。没有改相册拖放、UI 布局、RAW 解码、项目依赖、名称、图标、版本或许可证。

完整显示指实际绘制尺寸（ZoomFactor / Dpi）在 DrawingArea 内。导航按钮、图片外部空白、组合键、触摸、选区和自由平移不抢占；仅允许原生 Copy 文件效果，不提供 Move/Link，不为拖出另做一次图片解码。

## 通过项目

| 项目 | 证据与结果 |
|---|---|
| 编译 | Build-Preview.ps1 成功；最终 build-20261010-102940.log 无错误、无警告 |
| 补丁导出 | Export-PersonalPatches.ps1 成功，拖放与 Pro 两份独立补丁 |
| 干净基线恢复 | 临时索引 read-tree upstream/develop，然后 apply 两份补丁；三个源码文件的 Git blob 与当前工作区相同 |
| 模拟上游更新 | 临时索引中的 ViewerControl.cs 加一处不重叠注释变更，3-way 应用补丁后该变更和个人接入均保留；没有改真实工作区/分支 |
| 跨窗口复制 | 用户在真实预览中从大图拖到专用资源管理器文件夹，反馈复制成功、原图保留 |
| 内容完整性 | AI 读文件核实原件、副本均存在，SHA256 均为 5A670856AFCCD8CB7DB6EF10CFC12FF460925B7F018F26F783C208AF357C9D16 |
| 溢出平移 | 100% 显示的 1600×1000 合成图，在 720px 查看器左拖 120px，图像颜色分界由 x626 到 x506，仍为 100% |
| 单击 | 专用 QA 配置将左键单击绑定相册开关；普通单击能切换相册 |
| 双击 | 双击由 100% 恢复为 45% 适配窗口 |
| 拖后状态 | 同窗拖放结束后，相册显示状态与 45% 缩放保持稳定 |
| 左右切图 | Right 从 PNG 切换到同目录第二张 JPG，标题显示 2/2 |
| 空白检查 | git diff --check 通过 |

computer-use 不允许单次 drag 的终点超出源窗口矩形，拒绝了自动跨窗口拖动，因此该手势由用户人工完成。此限制不是应用失败。未通过脚本复制文件来冒充拖放成功。

## 产物

- ZIP：source/__artifacts/personal/ImageGlass_10.0.6.906_personal-drag_Lite_win-x64_20261010-102940.zip。
- 大小：67,544,710 字节，约 64.4 MiB。
- SHA256：FF785242C1FFA007D0B3D1E1802ECECA65740B075D0A856BA8A1CE9D486CE9DA。
- 本地 Lite 便携预览，需 .NET 10 Desktop Runtime x64。此机器已有该运行时；没有安装额外工具链。构建参数关闭 AOT、裁剪、单文件和 ReadyToRun，不改项目配置。
- 未签名、非官方 Release；不要让官方自动更新覆盖个人版。
- 测试 igconfig.json 在解压/运行目录内，交付 ZIP 不包含测试绑定。

详细日志与合成图片均位于忽略目录 source/__artifacts/personal/，其中 qa/copy-result.json 为独立哈希证据，qa/fitted-after-drag.jpg 和 qa/zoomed-after-pan.jpg 为窗口截图。

## 尚未验证

微信真实待发送效果、真实 Sony ARW 性能、多 DPI、其他平台、Esc 取消、文件消失、无真实文件的剪贴板图片、裁剪/触摸等边界尚未实测。源码中有对应资格/异常处理，但不能用代码判断代替实际验收。Pro 开关已保留，未逐项回归所有 Pro 功能。

不能保证未来任意上游自动无冲突。当前验证证明了干净基线能精确重建，以及一个不重叠上游改动的合并场景；未来大改时按 README 的功能契约重新适配。

## 提交与同步

用户本轮已授权提交、推送、打个人标签及发布到 fork；实际线上核验状态记录于 CODEX_PROGRESS.md。

## 自带运行时终包

2026-10-10 执行 Build-Package.ps1 -Revision drag.1 成功。ZIP 为 104408880 字节，SHA256：639d8e03497a06fab3b4ef02275497505623797b2be4046214f5432f4ea402ea。独立检查 464 个条目和初始中文/关闭更新配置，确认入口、运行时、LICENSE、.igportable 均存在。最终 ZIP 独立解压后真实桌面成功显示首次设置向导，简体中文已选中；未重复完整交互验收。证据见忽略目录 release/package-verification.json。
