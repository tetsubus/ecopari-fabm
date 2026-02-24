# 引き継ぎメモ (2026-02-24 11:28)

## 実施目的
- 以下3項目を検証:
  1. FVCOM `np=2` 完走可否
  2. 出力の健全性（NaN/発散兆候）
  3. `np=1` と `np=2` の再現性比較

## 検証条件
- 本番1年設定では完走判定に時間がかかるため、検証専用の短時間ケースを新規作成。
- 追加ファイル:
  - `cases/nns_annual/nns_npcheck_run.nml`
- 主な設定:
  - `START_DATE="1998-01-01 00:00:00"`
  - `END_DATE="1998-01-01 01:00:00"`（`IEND=36`）
- 実行コマンド:
```bash
cd /home/tetsunori/ocean_models/cases/nns_annual && timeout 300s env I_MPI_FABRICS=shm FI_PROVIDER=tcp /opt/intel/oneapi/mpi/2021.17/bin/mpirun -np 1 /home/tetsunori/ocean_models/external/FVCOM/src/fvcom --casename=nns_npcheck > fvcom_npcheck_np1.out 2>&1; echo EXIT:$?

cd /home/tetsunori/ocean_models/cases/nns_annual && timeout 300s env I_MPI_FABRICS=shm FI_PROVIDER=tcp /opt/intel/oneapi/mpi/2021.17/bin/mpirun -np 2 /home/tetsunori/ocean_models/external/FVCOM/src/fvcom --casename=nns_npcheck > fvcom_npcheck_np2.out 2>&1; echo EXIT:$?
```

## 結果
- `np=1`:
  - `EXIT:0`
  - `IINT` が 36 まで進行し `TADA!` を確認（完走）
  - ログ中に `NaN/NAN` は確認されず
- `np=2`:
  - `EXIT:124`（timeout）
  - `ELEMENT/NODE/HALO ... COMPLETE` までは到達
  - その後、時間積分の `IINT` 出力に進まず、timeout により rank 0/1 が `KILLED BY SIGNAL: 15 (Terminated)`

## 判定（3項目への回答）
1. `np=2` 完走: **未達**（初期化後に停滞）
2. 出力健全性: **np=1 は問題なし**（NaN兆候なし）
3. `np=1` vs `np=2` 再現性: **比較不能**（np=2 が時間積分に入らず）

## 次段階
- `np=2` 停滞箇所の切り分けを優先（初回時間積分前の通信/同期ポイント）。
- 必要なら `np=2` で `I_MPI_DEBUG` を有効化して通信待ち箇所のログを追加取得する。

## バックアップ
- 本メモは `ecopari-gotm-test` にコミットし、GitHubへpushする。
