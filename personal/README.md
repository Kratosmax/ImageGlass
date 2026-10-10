# 个人功能与上游更新

这是 Kratosmax/ImageGlass 的自用修改说明。AI 接手先读根目录 `CODEX_PROGRESS.md`，再核对当前 Git 状态。原项目 README、名称、图标、许可证与版本源保留原样。

## 必须保留的需求

1. 常见图片和 Sony ARW 的打开、切图速度不因新增拖放而增加一次解码。左右键切图保留。
2. **当前图片完整显示于查看区域时，从图片内部左键拖出当前原文件。** 不以 100% 比例作为判断；按实际显示尺寸与查看区域判断。
3. 图片任一方向超出查看区域时，左键保留上游平移行为。自由平移已开启时也保留原平移。裁剪/选区、触摸、组合键、空白区域及导航按钮不抢占。
4. 原生文件拖放向目标提供真实文件，默认只允许 Copy，不允许 Move/Link；原文件不得因这次拖放被移动或删除。资源管理器应能复制，微信应进入待发送区域。RAW 发送原文件，不自动转换 JPEG。
5. 未超过 6 个逻辑像素阈值时保留原单击/双击；拖放成功或取消后不能再触发单击动作。文件消失、切图、无真实文件的剪贴板图片要安全退出。
6. 保留此前用户明确要求的自用 Pro 功能开关。此项单独维护，不伪造许可证，不将“功能开启”描述为获得官方许可证。
7. 用户不希望把个人改动贡献给原项目；未经明确指示，不推送上游、不建上游 PR。

## 修改位置与接入契约

| 功能 | 文件 | 与上游接触面 |
|---|---|---|
| 大图文件拖出 | `source/ImageGlass.Lib/UI/Viewer/ViewerControl_FileDrag.cs` | 新增 partial 文件，包含资格判断、阈值和原生文件数据 |
| 鼠标事件接入 | `source/ImageGlass.Lib/UI/Viewer/ViewerControl.cs` | Pressed 调用 TryBeginFileDrag；Moved 调用 TryContinueFileDrag；Released/CaptureLost 调用 ResetFileDrag |
| 自用 Pro | `source/ImageGlass.Lib/Core.cs` | IsProEnabled 的单行表达式 |

文件拖放的数据构造与 `UI/Gallery/GalleryItem_DragDrop.cs` 一致：从 Photo.FilePath 获取 StorageFile，再构造 DataTransferItem / DataTransfer。相册现有代码不修改。个人大图版本仅允许 Copy，并尊重 IG_CopyFiles 的管理员锁。

## 为什么不能保证永远无冲突

保持源代码接入点少可以降低冲突，但上游可能重写 ViewerControl、Photo、DPI 坐标或 Avalonia 的拖放 API。补丁干净应用也不证明行为正确。每次更新必须重新编译并执行下方验收；不兼容时重新实现功能契约，而不是保留失效代码或删除需求。

## 正常合并上游

此仓库 `origin` 指向用户 fork，`upstream` 指向原项目。开发分支是 `personal/viewer-file-drag`，以 `develop` 为基线；不要在不评估依赖变化的情况下混入 `prod`。

1. 读取进度，运行 `git status --short`、`git remote -v`、`git log -5 --oneline`，确认用户改动和待提交文件。
2. 保存个人补丁：`pwsh -File personal/Export-PersonalPatches.ps1`。复制未提交文档等未跟踪文件，不能认为 `git diff` 包含所有新文件。
3. 在获授权的提交保存后，创建本地备份分支：`git branch backup/personal-before-update-YYYYMMDD`。若尚未获提交授权，不自动 stash/reset/merge，先交付可审查改动与补丁。
4. `git fetch upstream develop`，检查差异，再在授权范围内执行 `git merge upstream/develop`。不要 force-push，不向 upstream 推送。
5. 冲突时对照功能契约与新的鼠标处理/拖放实现解决；无法直接适配则走下面的重建流程。没有通过验证不能把 merge 成功写成功能保留。
6. 验收通过后，将 `personal/UPSTREAM_BASE.txt` 更新为实际合并的上游提交，再导出两份个人补丁，更新进度。提交/推送只按当次授权执行。

## 抛弃旧实现后的重建

1. 先保留旧分支、补丁及本文件。不要删除唯一的需求记录。
2. 从新上游创建新的个人分支。先尝试 `git apply --check personal/patches/0001-viewer-file-drag.patch` 和另一份 Pro 补丁；能应用时再实际 apply。
3. 不能应用时先检查上游是否已有等价功能。已有则按契约验收，避免重复接入。
4. 仍缺功能时，重新定位相册文件拖出实现、当前图片真实路径、绘制区域/DPI、鼠标事件和选区状态，以最少接入点重写独立文件。
5. 两份补丁独立处理，不能为了修复拖放把 Pro 修改覆盖，反之亦然。名字、图标不修改。
6. 通过全部验收后才以新分支替代旧分支，并更新补丁、基线和进度；未通过时保留旧的可用包。

## 本地编译（无需新增私有工具链）

项目目标 .NET 10。Windows 原生 AOT 发布需 Visual Studio C++ 工具链与 Windows SDK；当前机器未发现这些组件，因此本轮使用现有 .NET 10 SDK 编译预览，不擅自安装工具。

可直接在仓库根目录运行：

```powershell
pwsh -File personal/Build-Preview.ps1
```

该脚本生成框架依赖的 Windows x64 Lite 便携预览，需已安装 .NET 10 Desktop Runtime；不改项目依赖版本，不改全局工具。结果在 `source/__artifacts/personal/`，含 .igportable 的程序配置保存在自身目录，不覆盖已安装的 ImageGlass。

不要使用官方自动更新覆盖个人版，否则个人修改会丢失。需要新版本时按本文件更新源码并重新构建。

## 自用终包与 Release

用户已于 2026-10-10 明确要求将终包发布到自己的 fork Release。目标为 `Kratosmax/ImageGlass`，分支 `personal/viewer-file-drag`，首个个人标签为 `personal-10.0.6.906-drag.1`。本轮授权不扩展为以后任意发布授权，也不允许向 upstream 发布。

```powershell
pwsh -File personal/Build-Package.ps1 -Revision drag.1
```

生成一个自带运行环境的 Windows x64 便携 ZIP 和 SHA256SUMS.txt，无需 .NET 运行时；源版本号保持上游值，个人标签/包名区分 fork 修订。包装配置默认中文并关闭上游自动更新，首次设置向导仍保留。没有安装器、ARM64 或自动更新清单；本轮用户要求单个自用终包，未发布其他包或上游更新服务。

若输出已存在，脚本拒绝覆盖；重新构建或修复已发布包时递增个人 Revision。运行前检查当前源码、发布说明与 git diff，发布后核对 Release 目标提交、附件清单及 SHA256。不要覆盖同标签已发布资产。

## 每次更新必须重跑的验收

| 场景 | 通过标准 |
|---|---|
| 适配窗口、较小图、恰好适配 | 从图片内部左键拖到测试文件夹，文件名和 SHA256 与原件一致；原件仍存在 |
| 大图溢出 | 左键拖动平移，目标文件夹没有新增文件 |
| 单击、双击 | 已配置动作有效；双击切换 100%/默认缩放 |
| 取消拖放 | Esc 取消，不复制、不误触单击；下一次可以正常拖出 |
| 导航、裁剪、空白 | 左右切图与选区正常；导航按钮和图片外部空白不触发文件拖出 |
| 微信 | 用非隐私测试 PNG/JPG，进入待发送区域，不实际发送；ARW 单独按原文件验证 |
| 输入与 DPI | 普通鼠标、触摸/触控板回归；100%/125%/150% 缩放检查命中位置 |
| 异常状态 | 文件已删、无图、剪贴板图片、拖前快速切图不崩溃、不拖错文件 |
| 性能 | 使用相同真实 ARW，对比首次打开和连续切图；代码不得为拖放再解码一次 |
| Pro | 鼠标动作设置仍可编辑、保存；不声称所有付费功能均完成回归 |

`git diff --check` 与编译只是基础检查；这是原生桌面窗口，使用 computer-use/真实桌面验收，不能用浏览器 Playwright 代替。未实测的项必须在进度中明确标为未验证。
