# 文档与转换工作原则

以下原则适用于 Boost.Accumulators 等基于 **Quickbook / BoostBook → AsciiDoc → Antora HTML** 的文档维护与改造，以及配套工具（如 `boost-doc-modernize`）的修改。后续任务除非特意指出，应默认按此执行。

---

## 1. 全局检查原则

- 不仅修复任务中**明确列出的位置**，还要**主动在整个文档（及同类产物）中查找相同或相似问题**。
- 对典型模式（例如 variablelist 中的列表续行、跨页引用、资源路径、锚点命名）做检索与抽样核对，避免只修一处、漏掉十处。

---

## 2. 长远性原则

- 修改方案应**降低同类问题再次出现的概率**（可维护、可扩展、有明确约定）。
- 优先采用**规则化、可复用的修复**（转换器逻辑、构建脚本、统一后处理），避免依赖一次性手工改 HTML/ADoc。

---

## 3. 根源修复性原则

- **不仅修复 `adoc-html` 表面现象**，还要分析并修复 **Quickbook → AsciiDoc（及后续管线）中的机制缺陷**，包括但不限于：
  - 转换规则与标记解析；
  - 样式与结构映射（如列表、代码块、表格）；
  - 锚点生成与链接目标生成；
  - 资源路径与静态资源部署。
- 目标是解决**流程与机制**上的问题，而不是只打补丁；只有机制层面可靠，才能与**长远性原则**一致。

---

## 4. 最小影响原则

- 修改时**只动确有问题的部分**，不改动已正确渲染或与参考标准（如 `qbk-html`）一致的内容。
- 避免无关重构、大范围格式化或“顺手优化”，以免引入新回归。

---

## 参考标准与协作范围

- **行为与内容对照**：以既有 **qbk-html**（或约定的参考构建）为准。
- **转换工具**：在 `boost-doc-modernize` 等仓库中修改转换逻辑时，同样遵循上述四条，并保持与本文档约定一致（可在该仓库通过链接或简短 README 指向本文件）。

## 站点行为与遗留 HTML（实践备忘）

- **浏览器后退与滚动**：静态 `qbk-html` 依赖浏览器默认的滚动恢复；Antora 生成页在部分环境下会从网络重新加载文档导致回到页顶。应在 **UI 补充脚本**（如 `supplemental-ui/partials/footer-scripts.hbs`）中保持 `history.scrollRestoration = 'auto'`，并在必要时用 `sessionStorage` + `PerformanceNavigationTiming` 的 `back_forward` 在 `pageshow` 中补恢复（仅当非 `persisted` 时），与静态 HTML 体验对齐。
- **DocBook / Doxygen 独立页**：仅引用 `boostlook.css`、无 `.boostlook` 包装时，全局 `img { display: block }` 会破坏 `spirit-nav` 横向排列；应在 **`fix_reference_html_paths.py` / `fix_framework_ref_html.py`** 中注入内联样式或专用 CSS，避免仅依赖外链未加载的旧构建。

---

*文档版本：按项目需要随实践增补示例与检查清单。*
