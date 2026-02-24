# 引き継ぎメモ (2026-02-24 10:38)

## 目的
- セッションが切れても再開できるよう、直近の実行状態を保存する。
- 本メモを GitHub にバックアップし、端末障害時にも継続可能にする。

## 直近の事象（重要）
- `ELEMENT MAP ... COMPLETE` などの **実行ログ文字列をそのままコマンド実行** すると、
  - `/bin/bash: line X: ELEMENT: command not found`
  になる。
- これは FVCOM 計算失敗ではなく、シェル操作ミス。

## EXIT:124 の意味
- `Terminated` + `EXIT:124` は `timeout` 到達でプロセスが停止したことを示す。
- 実際に `run_np2.log` では MPI/FVCOM 初期化ログ（`ELEMENT MAP ... COMPLETE` まで）が出力されており、
  ログ貼り付けによるシェルエラーとは別事象。

## 正しい実行コマンド（再掲）
```bash
cd /home/tetsunori/ocean_models/cases/nns_annual && timeout 180s env I_MPI_FABRICS=shm FI_PROVIDER=tcp mpirun -np 2 /home/tetsunori/ocean_models/external/FVCOM/src/fvcom --casename=nns_annual 2>&1 | tee run_np2.log; echo EXIT:${PIPESTATUS[0]}
```

## 運用ルール（継続）
- 引き継ぎメモは作業区切りごとに `docs/handover_YYYY-MM-DD_HHMM_fvcom_fabm_ecopari.md` で新規作成。
- 毎回、`ecopari-gotm-test` ブランチへコミットし GitHub へ push してバックアップする。
