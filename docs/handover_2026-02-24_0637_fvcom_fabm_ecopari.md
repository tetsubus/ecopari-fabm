# 引き継ぎメモ (2026-02-24)

## 目的
- このメモは、チャットが途中終了しても次のセッションで即再開できるように残す。
- このメモ自体もローカルだけでなく GitHub にもバックアップする。
- GitHub バックアップ対象:
  - https://github.com/tetsubus/ecopari-fabm
  - https://github.com/tetsubus/FVCOM

## 直近の状況
- `mpirun` 実行で `HYD_sock_listen_on_port ... Operation not permitted` が出て `EXIT:255`。
- これはソケット制限の症状。

## sudo 実行時の注意
- `sudo` で `mpirun` が見つからない (`env: ‘mpirun’: No such file or directory`, `EXIT:127`)。
- 原因: `sudo` で `PATH` が初期化されるため。
- 対策: `mpirun` を絶対パスで指定。

## 実行コマンド (sudo, 絶対パス)
```bash
cd /home/tetsunori/ocean_models/cases/nns_annual && sudo timeout 180s env I_MPI_FABRICS=shm FI_PROVIDER=tcp /opt/intel/oneapi/mpi/2021.17/bin/mpirun -np 2 /home/tetsunori/ocean_models/external/FVCOM/src/fvcom --casename=nns_annual 2>&1 | tee run_np2.log; echo EXIT:${PIPESTATUS[0]}
```

## 進捗確認
```bash
tail -f /home/tetsunori/ocean_models/cases/nns_annual/run_np2.log
```

## バックアップ運用
- 引き継ぎメモは作業の区切りごとに **新規ファイル** として保存する。
  - 例: `ocean_models/docs/handover_YYYY-MM-DD_HHMM_fvcom_fabm_ecopari.md`
- 作成したメモはローカルだけでなく **GitHub にもバックアップ** する。
- GitHub へのバックアップは可能な限り頻繁に行い、PC 故障時でも新しいPCで再開できるようにする。
