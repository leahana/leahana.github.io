# Changelog

所有重要变更均记录于此。

## v2026.04 (2026-04-04)

> 初始 Release 节点：引入 git-cliff changelog 系统和 commit 规范标准化。
> 此前的历史提交不纳入 changelog，从此版本起开始追踪。

### ⚙️ CI/CD

- 新增 `cliff.toml` git-cliff 配置，支持文章 vs 基础设施两段式分组
- 新增 `.github/workflows/release.yml` 手动触发的月度 release 工作流
