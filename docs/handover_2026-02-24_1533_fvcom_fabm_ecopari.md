# 引き継ぎメモ (2026-02-24 15:33)

## 目的
- `np=2` 停滞がケース依存かを確認し、運用方針（`np=1`継続可否）を確定する。

## 実施内容
### A) nns_annual 側の追加確認（既実施分の要約）
- `timeout=900s`、`I_MPI_DEBUG=5`、`OMP_NUM_THREADS=1`、`BIOLOGICAL_MODEL=F` を試行。
- いずれも `np=2` は `ELEMENT/HALO ... COMPLETE` 以降で `IINT` が出ず `EXIT:124`。

### B) 別ケース nns_1d10 で再現確認（今回）
- 検証用ファイル: `cases/nns_1d10/nns_1d10_npcheck_run.nml`
  - `END_DATE="1998-01-01 01:00:00"`（IEND=36）
  - `RST_ON=F`, `NC_ON=F`（短時間確認向け）
- 実行:
  - `np=1`: `fvcom_nns1d10_npcheck_np1.out` -> `EXIT:0`、`IINT`進行と `TADA!` 確認
  - `np=2`: `fvcom_nns1d10_npcheck_np2.out` -> `EXIT:124`、`ELEMENT/HALO ... COMPLETE` 後に進展なし

## 判断
- `np=2` 停滞は `nns_annual` 固有ではなく、`nns_1d10` でも同様に再現。
- `timeout` を延ばせば解決する見込みは低い（180/300/900秒で同一地点停滞）。
- 当面の実務運用は `np=1` を採用する判断が妥当。

## 推奨運用（当面）
- 本番・検証とも `np=1` で進行。
- `np=2` は別トラックで MPI/FVCOM 側の根本切り分け（実行基盤/同期処理）として継続。

## バックアップ
- このメモと今回生成ログを `ecopari-gotm-test` にコミットして GitHub へ push する。
