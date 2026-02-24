# 引き継ぎメモ (2026-02-24 14:55)

## 方針
- `np=2` 停滞が継続するため、当面の本番/検証運用を `np=1` に固定して前進する。

## 今回の実施
1. `np=1` 実行スクリプトを追加
- 追加: `scripts/run-fvcom-np1.sh`
- 使い方:
```bash
/home/tetsunori/ocean_models/scripts/run-fvcom-np1.sh <case_dir> <casename> [timeout_sec] [logfile]
```
- 例:
```bash
cd /home/tetsunori/ocean_models/cases/nns_annual
/home/tetsunori/ocean_models/scripts/run-fvcom-np1.sh /home/tetsunori/ocean_models/cases/nns_annual nns_npcheck 300 fvcom_np1_opscheck_20260224.out
```

2. `nns_annual` で運用確認
- 実行ログ: `cases/nns_annual/fvcom_np1_opscheck_20260224.out`
- 結果: `EXIT:0`
- `IINT` 1〜36 の進行と `TADA!` を確認。
- ログ中に `NaN/NAN`、`BAD TERMINATION`、`ABORT` は確認されず。

## 結論
- `np=1` 運用はこの環境で安定して実行可能。
- 当面は `np=1` でタスクを継続する。

## バックアップ
- 本メモと関連ファイルは `ecopari-gotm-test` にコミットし、GitHubへpushする。
