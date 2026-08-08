# 專案層級 Agent Skills

放在此處的 skill 會隨 repo 走，任何人在本專案開 Claude Code 都能使用，
不必各自安裝。**不參與網站部署**（發布目錄是 `public/`）。

## 已安裝

| Skill | 來源 | 版本 | 用途 |
|-------|------|------|------|
| `frontend-design` | [anthropics/skills](https://github.com/anthropics/skills/tree/main/skills/frontend-design)（官方） | upstream `f17010c`（2026-08-07） | UI 視覺設計方向、字體搭配、避免樣板化的預設風格 |

## 更新方式

```bash
git clone --depth 1 https://github.com/anthropics/skills /tmp/anthropic-skills
diff -r /tmp/anthropic-skills/skills/frontend-design .claude/skills/frontend-design
# 確認差異後再覆蓋，並更新上表的版本欄
```

## 安裝其他官方 skill

官方 repo 尚有 `webapp-testing`、`skill-creator`、`mcp-builder`、`docx`／`pptx`／`xlsx`／`pdf`
等。本 session 已內建 `canvas-design`、`brand-guidelines`、`theme-factory`、
`web-artifacts-builder`、`algorithmic-art`，**不需重複安裝**——安裝前請先確認
是否已在可用清單中。

## 注意

- 新增 skill 後，**目前的 Claude Code session 不會即時載入**，需重開 session 才生效。
- 第三方 skill（非 `anthropics/skills` 內的）安裝前請先讀過 `SKILL.md` 全文：
  skill 內容會直接進入模型的指令脈絡，等同於讓它替你下指令。
