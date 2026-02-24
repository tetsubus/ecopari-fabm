# 引き継ぎメモ (2026-02-24 06:52)

## 目的
- セッションが切れても、次回すぐ再開できるように状況を保存する。
- このメモを GitHub にもバックアップして、端末障害時でも復旧できるようにする。

## 今回の続きで起きたこと
- 実行コマンドとして以下を入力:
  - `--casename=nns_annual 2>&1 | tee run_np2.log; echo EXIT:${PIPESTATUS[0]}`
- 結果:
  - `--casename=nns_annual: command not found`

## 原因
- `--casename=...` はオプションであり、先頭に実行本体（`fvcom` もしくは `mpirun ... fvcom`）が無いため、シェルが「コマンド名」と解釈して失敗した。

## 正しい再実行コマンド（この環境向け）
```bash
cd /home/tetsunori/ocean_models/cases/nns_annual && timeout 180s env I_MPI_FABRICS=shm FI_PROVIDER=tcp mpirun -np 2 /home/tetsunori/ocean_models/external/FVCOM/src/fvcom --casename=nns_annual 2>&1 | tee run_np2.log; echo EXIT:${PIPESTATUS[0]}
```

## 補足
- もし `HYD_sock_listen_on_port ... Operation not permitted` が再発する場合は、直前メモ `docs/handover_2026-02-24_0637_fvcom_fabm_ecopari.md` の sudo + 絶対パス版コマンドを使用する。

## バックアップ実施記録
- このメモは `ocean_models` リポジトリにコミットし、`origin/ecopari-gotm-test` へ push する。
