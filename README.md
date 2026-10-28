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
