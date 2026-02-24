# 引き継ぎメモ (2026-02-24 14:23)

## 追加切り分け（np=2 停滞）
前回の `nns_npcheck`（1時間ケース, IEND=36）で `np=2` が `ELEMENT MAP/HALO NODES COMPLETE` 後に進まない件を追加検証した。

## 実施した検証
1. timeout延長
- コマンド: `timeout 900s ... mpirun -np 2 ... --casename=nns_npcheck`
- ログ: `cases/nns_annual/fvcom_npcheck_np2_t900.out`
- 結果: `EXIT:124`
- 観測: `IINT` 進行ログなし。`ELEMENT/HALO ... COMPLETE` 以降で timeout により終了。

2. MPIデバッグ有効化
- コマンド: `I_MPI_DEBUG=5 timeout 180s ... mpirun -np 2 ... --casename=nns_npcheck`
- ログ: `cases/nns_annual/fvcom_npcheck_np2_dbg.out`
- 結果: `EXIT:124`
- 観測: Intel MPI startup 情報は出るが、`IINT` に進まず。

3. OpenMP固定
- コマンド: `OMP_NUM_THREADS=1 timeout 300s ... mpirun -np 2 ... --casename=nns_npcheck`
- ログ: `cases/nns_annual/fvcom_npcheck_np2_omp1.out`
- 結果: `EXIT:124`
- 観測: 挙動変化なし。

4. 生物モデルOFFの対照試験
- 追加ファイル: `cases/nns_annual/nns_npcheck_nobio_run.nml` (`BIOLOGICAL_MODEL=F`)
- コマンド: `timeout 300s ... mpirun -np 2 ... --casename=nns_npcheck_nobio`
- ログ: `cases/nns_annual/fvcom_npcheck_nobio_np2.out`
- 結果: `EXIT:124`
- 観測: 生物モデルOFFでも同じ位置で進まず。

## 判断
- 「timeout を長くすれば終わる」可能性は低い。
- 少なくとも 180s / 300s / 900s の全条件で、`np=2` は同一地点から進展しない。
- 停滞は FABM/EcoPARI 固有ではなく、`np=2` 実行経路（FVCOM側MPI同期または直後の処理）にある可能性が高い。

## 次の推奨切り分け
- FVCOM（BIOLOGICAL_MODEL=F）のより単純な最小ケースでも `np=2` を実施し、モデル固有条件か MPI実行基盤かを分離。
- 必要に応じて MPI 実装/ランチャ設定の変更（例: 別MPI、ランチャオプション）を試す。

## バックアップ
- 本メモと追加ログは `ecopari-gotm-test` へコミットして GitHub に push する。
