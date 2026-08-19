# Netcore N60 Pro OpenWrt CI

本仓库仅用于构建磊科 Netcore N60 Pro 固件，不包含其他设备的构建配置。

## 构建信息

- 设备：Netcore N60 Pro
- 平台：MediaTek Filogic / MT7986A
- 上游源码：<https://github.com/VIKINGYFY/immortalwrt.git>
- 上游分支：`owrt`
- 固件配置：[`Config/N60-PRO.txt`](Config/N60-PRO.txt)
- 编译工作流：[`N60-PRO.yml`](.github/workflows/N60-PRO.yml)

## 自动构建

GitHub Actions 每周一北京时间 05:15 检查上游分支的最新提交：

- 上游提交发生变化时，自动构建并发布 N60 Pro 固件；
- 上游提交没有变化时，跳过编译；
- 构建失败时不会记录成功标记，下一次检查会自动重试；
- Release 清理任务每周一北京时间 05:00 运行，并保留最近 3 个 N60 Pro 固件版本；
- 构建日志清理任务每周一北京时间 05:05 运行，清理已完成的 Actions 运行记录。

也可以在 Actions 页面手动运行 `N60-PRO`。默认启用 `FORCE`，可在上游没有变化时强制重新构建；启用 `TEST` 时只生成最终配置文件，不编译固件。

## AI 选择性同步 Scripts

`Scripts-Sync` 每天北京时间 04:00 检查 CI 上游，仅分析 `Scripts/` 目录的变化。其他设备配置、工作流和仓库文件不会进入 AI 候选列表。

同步策略：

- 上游新增的通用脚本可由 AI 选择后引入；
- 已有脚本以本地版本为准，AI 只选择性合并有用的上游修改；
- 上游删除、重命名、高风险或无法判断的变化不会自动处理；
- 合并结果必须通过 N60 Pro 专属目录检查、冲突标记检查、`bash -n`、ShellCheck 和 `git diff --check`；
- 验证完成后更新 `bot/scripts-sync` 分支并创建 PR；仅在明确启用自动合并且 AI 未标记高风险时尝试自动合并。

在仓库 `Settings → Secrets and variables → Actions` 中配置：

| 类型 | 名称 | 说明 |
| --- | --- | --- |
| Secret | `AI_API_KEY` | AI 接口密钥 |
| Variable | `AI_BASE_URL` | API 根地址，通常包含 `/v1`，末尾不要包含具体接口路径 |
| Variable | `AI_MODEL` | 自定义模型名称 |
| Variable | `AI_API_MODE` | `responses` 或 `chat_completions`，默认 `responses` |
| Variable | `AI_STRUCTURED_OUTPUT` | 接口支持 JSON Schema 时设为 `true`，默认 `false` |
| Variable | `AI_AUTO_MERGE` | 允许定时任务自动合并安全 PR 时设为 `true`，默认 `false` |
| Variable | `UPSTREAM_REPO` | CI 上游仓库，默认 `VIKINGYFY/OpenWRT-CI` |
| Variable | `UPSTREAM_BRANCH` | CI 上游分支，默认 `main` |

自定义 AI 服务必须兼容所选的 OpenAI API 请求格式。不要在 `AI_BASE_URL` 中嵌入密钥。

此外需要在 `Settings → Actions → General` 中允许 Workflow 使用读写权限并创建 Pull Request。若启用 `AI_AUTO_MERGE`，还需要在仓库 Pull Request 设置中启用 Auto-merge；分支保护仍可要求检查或人工审核。

## 产物命名

Release 标签采用 `N60-PRO-年.月.日-时.分-上游提交` 格式，例如：

`N60-PRO-2026.08.19-11.23-cb29312`

主要固件文件沿用相同的时间和提交标识，例如：

- `netcore-n60-pro-bl31-uboot-2026.08.19-11.23-cb29312.fip`
- `netcore-n60-pro-initramfs-recovery-2026.08.19-11.23-cb29312.itb`
- `netcore-n60-pro-squashfs-sysupgrade-2026.08.19-11.23-cb29312.itb`
- `netcore-n60-pro-config-2026.08.19-11.23-cb29312.txt`

## 目录说明

- `Config`：N60 Pro 固件配置
- `Scripts`：软件包与默认设置脚本
- `.github/workflows`：自动检查、编译、发布和清理工作流

## License

[MIT](LICENSE)
