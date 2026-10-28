# Simplified Rime

This folder is a simplified bundle generated from currently enabled schema(s).

## Included scope

- Active schema in `default.yaml`:
  - `moqi_sogou`
- Required schema/dictionary files for:
  - `moqi_sogou`
  - `reverse_moqima`
  - `zrlf`
  - `emoji`
  - `easy_en`
  - `jp_sela`
  - `moqi_big`
- Shared runtime resources used by this setup:
  - `lua/`
  - `opencc/`
  - `cn_dicts_moqi/`
  - `cn_dicts_common/`
  - `custom_phrase/`

## Notes

- `default.custom.yaml` is provided and forces schema list to only `moqi_sogou`.
- `stroke.schema.yaml` is copied from `build/stroke.schema.yaml` (source tree has no root `stroke.schema.yaml`).
- User data directories (`*.userdb/`), build outputs, and unrelated schemas are intentionally excluded.

## How to use

1. Keep this folder as an isolated profile copy.
2. If you need more features later, copy related `*.schema.yaml`, `*.dict.yaml`, or resource directories from parent folder.
3. Re-deploy Rime after replacing config files.

## 当前方案功能与快捷键

当前启用方案为 `moqi_sogou`（墨奇辅助码 + 搜狗双拼）。尖括号中的内容表示需要替换的输入内容，例如 `ae<关键词>` 中的 `<关键词>` 不要原样输入。

### 前缀输入功能

| 功能 | 输入方式 | 说明 |
| --- | --- | --- |
| Emoji | `/关键词` 或 `ae关键词` | 搜索 Emoji；没有正在输入的编码时，`/` 可直接开始搜索。 |
| 英文词典 | `aw关键词` | 搜索英文单词，可使用去元音形式。 |
| 日语词典 | `aj关键词` | 搜索日语词条。 |
| 墨奇反查 | `amq编码'` | 按墨奇码反查汉字。 |
| 小鹤部件组字 | `az编码'` | 按部件编码组字。 |
| 自然两分反查 | `alf编码'` | 按自然两分编码反查。 |
| 仓颉反查 | `arj编码'` | 按仓颉五代编码反查。 |
| 笔画反查 | `ab笔画'` | 用 `h`（横）、`s`（竖）、`p`（撇）、`n`（捺）、`z`（折）输入笔画编码。 |
| 自造词 | `ac编码` | 在自造词输入段中按当前方案编码添加词条。 |
| 日期、时间、星期 | `date`、`time`、`week` | 分别输出当前日期、时间或星期候选。 |
| 日期时间格式 | `datetime` | 输出当前日期时间候选。 |
| Unix 时间戳 | `timestamp` | 输出当前时间戳（秒）。 |
| 农历 | `anl` 或 `NYYYYMMDD` | `anl` 转换当前日期；例如 `N20240115` 将指定公历日期转换为农历。 |
| 数字转中文金额 | `R数字` | 例如 `R1234.56`，显示中文数字/金额候选。 |
| Unicode 字符 | `U十六进制码位` | 例如 `U1F600`。 |
| 计算器 | `V表达式` | 例如 `V1+2*3`。 |
| 身份证号候选 | `C数字` | 根据已输入数字生成/补全身份证号候选；请勿将随机补全结果当作真实身份信息。 |

### 快捷键

| 按键 | 作用 |
| --- | --- |
| `F4` 或 `Ctrl+Shift+\`` | 打开方案选项菜单，可切换中/英文、简繁、Emoji、拆分、大字集等状态。 |
| `Ctrl+Shift+3` | 切换中英文标点；部分键盘布局也可用 `Ctrl+Shift+#`。 |
| `Ctrl+Shift+4` | 切换简繁；部分键盘布局也可用 `Ctrl+Shift+$`。 |
| `Tab` / `Shift+Tab` | 输入编码时，将光标移到下一个/上一个拼音音节。 |
| `,` / `.` | 候选菜单向上/向下翻页。 |
| `Ctrl+M` | 提交当前输入。 |
| `Ctrl+W` | 发送 `Ctrl+Backspace`，删除前一个输入段。 |
| `Ctrl+I` / `Ctrl+O` | 输入过程中将光标移到下一个/上一个音节。 |
| `Ctrl+1` 至 `Ctrl+7` | 将光标定位到对应音节后并打开辅助码输入；补完后可按 `Tab` 回到整句检查。 |
| 候选菜单中 `Shift+A` 至 `Shift+Z` | 将对应的大写辅助码加入整句第一个音节。 |
| 输入 1–3 个字母后按 `/` 或 `Tab` | 快速选择第 1 个候选。若尚未输入编码，单独按 `/` 可用于 Emoji 搜索。 |

在候选菜单中按 `Ctrl+E` 可切换中文转英文显示。小键盘在输入状态下可输入数字及 `.`、`+`、`-`、`*`、`/`，可用于计算器和金额转换。

### 可切换状态

在 `F4` 选项菜单中可切换以下状态：

- 中文 / 西文（`ascii_mode`）
- 半角 / 全角
- 简体 / 繁体
- Emoji 转换
- 墨奇码拆分
- 大字集 / 小字集
- 普通文字 / 火星文
- 中文 / 西文标点

当前配置会保存 `ascii_mode` 等选项状态，因此重新切回方案时可能恢复上次的中英文状态。

## Input performance

- The key-layout rules in `moqi_sogou.schema.yaml` under `speller/algebra`
  are applied during deployment to build the prism index. They do not run
  for each keystroke. Rewriting the shared dictionaries into Sogou codes
  is therefore not a typing-speed optimization; keep these rules to preserve
  the current layout, auxiliary codes, and dictionary compatibility.
- `lua/pro_comment_format.lua` reads its configuration once when Rime
  initializes the filter, rather than on every candidate refresh. It only
  initializes the correction table when correction hints are enabled.
  Without `pro_comment_format` configuration (the current setup), candidates
  and their comments pass through unchanged.
- Re-deploy/reload Rime after changing the filter or its configuration.
  This optimization reduces repeated Lua work, not the cost of dictionary
  lookup or other filters; it does not imply a measured end-to-end speedup.

### Regression tests

With Lua 5.4 or newer available, run from the project directory:

```powershell
lua .\tests\pro_comment_format_test.lua
```

The tests cover unconfigured passthrough, hint settings, completion candidates,
independent schema settings, and the absence of configuration reads during
candidate refreshes.
