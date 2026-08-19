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
