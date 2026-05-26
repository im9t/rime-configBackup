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
