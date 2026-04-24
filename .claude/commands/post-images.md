---
name: "Post Images"
description: 为已完成的博客文章批量生成 Mermaid 插图，回填原文并提交到 blog-images
category: Content
tags: [blog, mermaid, m2c, images, workflow]
---

为一篇已经写完的文章执行 Mermaid 插图收尾流程。

适用场景：
- 文章已经基本定稿，Markdown 中含有 fenced `mermaid` 代码块
- 需要通过 `m2c-pipeline` 生成 Chiikawa 风格插图
- 需要把图片 Markdown 追加回原文
- 需要把生成图片提交到相邻仓库 `../blog-images` 的 `dev` 分支，等待 CDN / 部署链路生效

推荐调用方式：

```text
/post-images source/_posts/tech/ai/2025-04-24-mcp-model-context-protocol.md
```

如果没有传入参数：
- 优先从当前会话里正在编辑的文章推断目标
- 若存在多个候选文章，必须先让用户确认，不要猜

## Workflow

1. **确认目标文章**

   - 目标文件必须位于 `source/_posts/` 下
   - 不允许重命名文章文件
   - 读取文章并统计 `mermaid` fenced block 数量
   - 如果没有 Mermaid 图，直接停止并告诉用户

2. **推导图片目录**

   - 文章相对路径去掉前缀 `source/_posts/` 和后缀 `.md`
   - 将结果作为 `blog-images` 仓库中的目标目录
   - 示例：
     - `source/_posts/tech/ai/2025-04-24-demo.md`
     - 对应 `../blog-images/tech/ai/2025-04-24-demo/`
   - 若目录不存在则创建

3. **使用 `m2c-pipeline` 生成图片**

   - 明确使用 `$m2c-pipeline` skill
   - 按该 skill 的要求定位 `m2c-pipeline` 工作区、完成 preflight，并沿用其标准运行方式
   - 优先对整篇文章执行生成，而不是手工拆 Mermaid 片段重写 prompt
   - 生成输出目录使用推导出的文章图片目录
   - 保留 `m2c-pipeline` 的运行痕迹文件（例如 `_runs/`）用于追踪，不要删除
   - 若缺少运行所需环境（例如 Vertex 凭据、Python 环境、repo checkout），按 skill 指引处理并把阻塞点告诉用户

4. **把图片回填到原文**

   - 为每个 Mermaid 图在其代码块后面追加对应图片引用
   - 默认使用 `m2c-pipeline` 实际产出的 PNG 文件名，不强行重命名
   - 图片链接必须使用：
     - `CDN_BASE + {相对图片路径}`，其中 `CDN_BASE` 表示
       `https://cdn.jsdelivr.net/gh/leahana/blog-images@dev/`
   - 追加格式优先使用下面这个模板：

   ```markdown
   <details>
   <summary>**🖼️ 插图版（YYYY-MM-DD 增量补充）**</summary>

   ![这里写该图的中文说明](CDN_BASE/tech/ai/post-slug/image.png)

   </details>
   ```

   - 如果 Mermaid 后方已经有同一路径或同一批次插图，就不要重复追加
   - alt 文本要根据图的主题写成简洁中文，不要只写“示意图”或“image”
   - 不要删除原有 Mermaid，图片是补充，不是替代

5. **维护文章元数据**

   - 如果这次属于对既有文章的内容增强，按仓库规范补或更新 `更新记录`
   - 版本语义：
     - 首次补图通常追加一个 `v1.x`
     - 大改重写才用 `v2.0`
   - 说明要简洁，例如：`为 3 个 Mermaid 图表追加 Chiikawa 风格插图（m2c-pipeline 生成）`
   - 保持原始文件名和原始发布日期不变

6. **提交 `blog-images` 仓库**

   - 只提交本次新增或更新的图片及运行产物，不要顺手提交无关文件
   - 如果仓库里出现 `.DS_Store` 等无关文件，不要把它们加入提交
   - 在 `../blog-images` 仓库执行：
     - 检查当前分支，应为 `dev`
     - `git status --short` 确认改动范围
     - `git add` 仅添加目标文章目录下本次产物
     - 创建提交，提交信息建议：
       - `content(images): add Mermaid illustrations for <post-slug>`
   - 不要自动 push，除非用户明确要求

7. **收尾验证**

   - 检查文章中的 CDN 链接是否都指向 `@dev`
   - 如条件允许，可提醒用户后续在 hexo 仓库运行或等待 `bin/check-images.sh`
   - 最终汇报：
     - 处理的文章
     - 识别到的 Mermaid 数量
     - 生成出的图片文件
     - 原文中追加了哪些图片块
     - `../blog-images` 是否已提交、是否尚未 push
     - 任何阻塞项或人工确认点

## Guardrails

- 不要重命名文章文件
- 不要删除原 Mermaid 代码块
- 不要覆盖用户已有但与你无关的修改
- 不要提交 `../blog-images` 里的无关脏文件
- 不要自动 push 两个仓库，除非用户明确要求
- 如果无法把生成结果与 Mermaid 顺序稳定对应，先停下来说明，不要盲目回填错误图片

## Output Style

执行时使用简洁状态播报，完成后总结：

- 文章路径
- Mermaid 数量
- blog-images 目标目录
- 新增 PNG 列表
- 原文回填结果
- `blog-images` 提交 hash（如果已提交）
- 下一步建议（例如是否需要我继续 push）
