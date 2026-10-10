# ImageGlass 个人 fork 接续进度

## 接手校准

先完整读取 `AGENTS.md`、本文件、`personal/README.md` 和上游 `README.md`。不要只信本文件中的旧快照。

```powershell
git status --short
git remote -v
git branch --show-current
git log -5 --oneline
git rev-list --left-right --count HEAD...upstream/develop
git diff --check
```

某些环境克隆目录的所有者不同，会提示 dubious ownership；必要时在每条 git 命令前增加 `git -c safe.directory=<当前仓库绝对路径>`，不要修改全局 safe.directory。

## 当前快照（2026-10-10）

- origin：`git@github.com:Kratosmax/ImageGlass.git`；upstream：`https://github.com/d2phap/ImageGlass.git`。
- 当前分支：`personal/viewer-file-drag`。基线：`2cf91deeec36310ff1b05d0a9039519179d5534b`，开始修改前 fork 与上游 develop 一致（fetch 后基线左右差异为 0/0）。上游 prod 为 `a8754cba`，没有混入 prod。
- 版本唯一来源：`source/Directory.Build.props`，10.0.6.906；develop 的依赖版本与此前稳定版快照不同，不降级依赖。
- 用户选定：完整显示时左键拖出；超出窗口时左键平移。相册栏拖出原文件已由用户验证可用。
- 新功能主体在独立 partial 文件；现有 ViewerControl 加 10 行接入。自用 Pro 单行修改独立保存。
- 状态：核心实现、本地 Lite 预览、资源管理器复制与基础交互验收已完成。个人分支与标签已推送 origin，终包 Release 已正式发布并完成线上校验，支持从个人分支跨设备接续。详情见文末发布记录。

## 已授权工作与当前待办

1. 已完成：完整显示时左键拖出原文件，溢出窗口时保留左键平移；原相册实现不改。
2. 已完成：Lite 预览构建和基础交互验证；用户人工确认跨窗口复制，AI 独立核对文件哈希。
3. 已完成：拖放与 Pro 分别导出补丁，在干净上游基线重放后 3 个文件 Git blob 完全一致；模拟同一上游文件的一处不重叠修改，3-way 应用后两边改动均保留。
4. 当前没有阻塞核心交付。剩余可选验收：微信、真实 ARW、多 DPI、Esc 取消、触摸/裁剪边界。需用户指定样片/目标后继续，不把未测项写成通过。
5. 本轮按用户要求发布一份自带运行时的终包，提交个人分支、文档和补丁并推送 origin；绝不推送 upstream。最终同步状态见发布记录。

## 当前改动文件

- `source/ImageGlass.Lib/UI/Viewer/ViewerControl_FileDrag.cs`：新增完整显示图片的原生 Copy 拖放。
- `source/ImageGlass.Lib/UI/Viewer/ViewerControl.cs`：四个指针事件接入。
- `source/ImageGlass.Lib/Core.cs`：保留自用 Pro 功能开启。
- `AGENTS.md`、`CODEX_PROGRESS.md`、`personal/README.md`、`personal/UPSTREAM_BASE.txt`：长期需求、基线、恢复约束和接续入口。
- `personal/Export-PersonalPatches.ps1`、`personal/Build-Preview.ps1`：不安装工具、不提交推送的补丁导出及预览构建。
- `personal/patches/0001-viewer-file-drag.patch`、`personal/patches/0002-personal-pro.patch`：独立恢复补丁。
- `personal/VALIDATION.md`：本轮验证结果、产物和未验证项。

## 构建与验证

- 当前机器已有 .NET SDK 10.0.201。未发现 Visual Studio C++ 工具链和 Windows SDK；不擅自安装，不创建工具私有副本。
- Lite 预览：`pwsh -File personal/Build-Preview.ps1`，框架依赖、非 AOT，需 .NET 10 Desktop Runtime；产物和日志在被上游忽略的 `source/__artifacts/personal/`。
- 补丁：`pwsh -File personal/Export-PersonalPatches.ps1`，分别维护拖放与 Pro。
- Native UI 用 computer-use 验证；浏览器 Playwright 不能替代原生文件拖放验收。
- 本轮成功测试（2026-10-10）：
  - `pwsh -File personal/Build-Preview.ps1`：成功，build-20261010-102940.log 为 0 错误、0 警告。
  - `git diff --check`：通过（Git 提示 LF/CRLF 转换，但没有空白错误）。
  - `pwsh -File personal/Export-PersonalPatches.ps1`，临时 GIT_INDEX_FILE 下 read-tree/apply 检查和实际重放：通过，三个文件 blob 与工作区一致。
  - 临时索引模拟不重叠上游改动后 `git apply --cached --3way`：通过，模拟上游改动与 TryBeginFileDrag 接入均保留。不能由此保证任意未来版本兼容。
  - 真实预览打开合成 PNG/JPG；普通单击自定义动作有效，双击从 100% 返回 45% 适配；100% 溢出时拖动 120px，图片边界同步平移 120px；方向键切换至 JPG 正常。
  - 用户反馈“复制成功，原图保留”；AI 校验测试 PNG 原件与副本均存在且 SHA256 相同：`5A670856AFCCD8CB7DB6EF10CFC12FF460925B7F018F26F783C208AF357C9D16`。
  - 同窗拖放结束后没有改变绑定的相册显示状态或缩放。跨窗自动拖动被 computer-use 的终点边界检查拒绝，因此跨窗手势由用户执行，没有伪称自动化通过。
- 预览 ZIP：`source/__artifacts/personal/ImageGlass_10.0.6.906_personal-drag_Lite_win-x64_20261010-102940.zip`。
  - 67,544,710 字节；SHA256：`FF785242C1FFA007D0B3D1E1802ECECA65740B075D0A856BA8A1CE9D486CE9DA`。
  - 框架依赖的非 AOT 本地 Lite 预览，需 .NET 10 Desktop Runtime x64；没有正式代码签名，不是官方 Release。
- 证据：`source/__artifacts/personal/qa/copy-result.json`、`qa/fitted-after-drag.jpg`、`qa/zoomed-after-pan.jpg`、`patch-replay-results.json`。产物/测试数据被忽略，不包含私人照片；验收配置不在 ZIP 中。
- 未验证：真实 Sony ARW 打开速度、微信接收效果、各 DPI/平台、Esc 取消、文件消失/剪贴板/裁剪/触摸等边界。未声称所有 Pro 功能已逐项回归。

## 更新与回滚约束

- 不保证未知未来上游自动无冲突合并。以独立补丁 + 功能契约 + 验收矩阵确保可以重新适配。
- 不向原项目 push/PR；本轮已授权发布到个人 fork。
- 更新前保留旧分支和完整修改记录。不能用 reset --hard 抹掉唯一的个人需求和实现。
- 上游重写相关模块时，根据新代码重做同一需求并重新验收，不能删掉功能后声称更新成功。
- 名称、图标、版本、许可证不修改；不泄露凭据/用户数据。个人 Pro 功能开关不代表官方许可证。
- 若提交/推送未完成，只能从当前本地仓库接续；跨设备需要当次授权同步后才能成立。

## 终包构建与核验（2026-10-10）

- 命令：pwsh -File personal/Build-Package.ps1 -Revision drag.1；成功，自带运行时、非 NativeAOT，未安装工具。
- ZIP：source/__artifacts/personal/release/ImageGlass_10.0.6.906_personal-drag.1_win-x64.zip；104408880 字节。
- SHA256：639d8e03497a06fab3b4ef02275497505623797b2be4046214f5432f4ea402ea。
- 464 个 ZIP 条目；入口、运行时、许可证、便携标记和初始配置均存在，实际哈希匹配。
- 从最终 ZIP 独立解压，真实桌面显示首次设置向导，简体中文已选中。终包未重复完整交互回归；上述交互结果来自此前 Lite 预览。
- 新增文件：personal/Build-Package.ps1、personal/RELEASE_NOTES_CURRENT.md；更新 personal/README.md、personal/VALIDATION.md 和本文件。
- 证据位于忽略目录 source/__artifacts/personal/release/package-verification.json 和 build-drag.1.log。

## 已发布与远程同步（2026-10-10）

- Release：https://github.com/Kratosmax/ImageGlass/releases/tag/personal-10.0.6.906-drag.1
- 标签：personal-10.0.6.906-drag.1；固定发布提交：4662d0c7800c86a6b15a3bfa37d207ff232571cc。后续文档收尾提交不改变此标签或产物。
- 功能提交：6589790a（拖出）、72039ead（自用 Pro）；维护文档/脚本提交：4662d0c7。
- 已正式发布（draft=false），共两个附件：终包 ZIP 与 SHA256SUMS.txt。线上 ZIP 大小 104408880 字节，GitHub SHA256 digest 与本地一致；线上校验文件已下载回读、内容与本地一致。
- 线上证据：忽略目录 release/github-published.json、release/online-check/SHA256SUMS.txt。
- 源码与文档已同步个人分支，没有向 upstream 推送或创建 PR。无剩余发布阻塞；尚未实测项保持上述记录。
- 空白检查：源码/文档通过；提交补丁文件本身时，diff --check 将 unified diff 的空白上下文行报告为空白提示，因此检查排除 personal/patches/*.patch；不删除补丁必需的上下文前缀。
