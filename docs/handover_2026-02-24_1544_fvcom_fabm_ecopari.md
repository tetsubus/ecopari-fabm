# 引き継ぎメモ (2026-02-24 15:44)

## 実施内容
- `np=1` 運用で `nns_annual`（1年設定）を実行。
- 実行コマンド:
```bash
cd /home/tetsunori/ocean_models/cases/nns_annual
/home/tetsunori/ocean_models/scripts/run-fvcom-np1.sh /home/tetsunori/ocean_models/cases/nns_annual nns_annual 1800 fvcom_np1_nns_annual_20260224.out
```

## 結果
- スクリプト終了コード: `EXIT:0`
- ログ: `cases/nns_annual/fvcom_np1_nns_annual_20260224.out`
- 最終時刻: `IINT=315360`（`1998-12-31T23:59:60.500000`）
- 終端: `TADA!`
- `NaN/NAN`, `BAD TERMINATION`, `ABORT` は確認されず。

## 判断
- 現環境では `np=1` で `nns_annual` 1年ケースを安定完走できる。
- 当面の本運用は `np=1` 継続で妥当。

## バックアップ
- 本メモと実行ログを `ecopari-gotm-test` にコミットして GitHub に push する。
