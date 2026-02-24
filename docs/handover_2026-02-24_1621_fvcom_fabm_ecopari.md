# 引き継ぎメモ (2026-02-24 16:21)

## 今回の到達点（GOTM-FABM-EcoPARI 10層）
- ユーザー要望: 「鉛直10層計算のために必要入力を整理し、適当な（例: 年周期サイン）入力ファイルを作成」。
- 新規ケースを作成:
  - `cases/nns_1d10_gotm_synth/`
- 既存からコピーした設定/連携ファイル:
  - `gotm.yaml`, `fabm.yaml`, `ecosystem.dat`, `sysin`

## 追加・変更したファイル
1. 生成スクリプト
- `scripts/generate-gotm-synthetic-inputs.sh`
- 機能:
  - 1年分（開始〜終了時刻を含む）の合成入力を生成
  - 生成対象:
    - `meteo_sine_1y.dat`
    - `sst_sine_1y.dat`
    - `t_prof_sine_1y.dat`
    - `s_prof_sine_1y.dat`
    - `ext_press_sine_1y.dat`
    - `zeta_sine_1y.dat`

2. ケース設定更新
- `cases/nns_1d10_gotm_synth/gotm.yaml`
- 主な更新:
  - 期間を `1998-01-01 00:00:00` 〜 `1999-01-01 00:00:00` に設定
  - 各入力ファイル参照先を `*_sine_1y.dat` に変更
  - `mimic_3d.zeta.method` を `file` に変更
  - 出力名を `nns_1d10_gotm_synth` に変更

3. 入力一覧ドキュメント
- `cases/nns_1d10_gotm_synth/INPUT_FILES.md`
- 現設定で必要な入力ファイルの一覧と列定義、再生成コマンドを記載

## 実行確認
- 実行コマンド:
```bash
cd /home/tetsunori/ocean_models/cases/nns_1d10_gotm_synth
/home/tetsunori/ocean_models/gotm/build_ecopari/gotm gotm.yaml > run_synth_check.log 2>&1
```
- 結果:
  - `EXIT:0`
  - 1年計算が `integrate_gotm ... 100%` まで進み完了
  - `GOTM finished` を確認
- 主要生成物:
  - `nns_1d10_gotm_synth.nc`
  - `restart.nc`
  - `run_synth_check.log`

## 中断時点の意図
- ユーザー指示により一旦中断。
- 次回は、この合成入力をベースに値レンジ・季節位相・境界条件の現実化を進めればよい。

## バックアップ
- 本メモと今回追加ファイルを `ecopari-gotm-test` へコミットし、GitHubへpushする。
