#!/usr/bin/env bash
set -euo pipefail

CASE_DIR="${1:-/home/tetsunori/ocean_models/cases/nns_1d10_gotm_synth}"
START="${2:-1998-01-01 00:00:00}"
STOP="${3:-1999-01-01 00:00:00}"

METEO_FILE="$CASE_DIR/meteo_sine_1y.dat"
SST_FILE="$CASE_DIR/sst_sine_1y.dat"
TPROF_FILE="$CASE_DIR/t_prof_sine_1y.dat"
SPROF_FILE="$CASE_DIR/s_prof_sine_1y.dat"
EPRESS_FILE="$CASE_DIR/ext_press_sine_1y.dat"
ZETA_FILE="$CASE_DIR/zeta_sine_1y.dat"

mkdir -p "$CASE_DIR"

to_epoch() {
  date -u -d "$1" +%s
}

fmt_time() {
  date -u -d "@$1" '+%Y-%m-%d %H:%M:%S'
}

# 6-hour meteo and sst
start_epoch="$(to_epoch "$START")"
stop_epoch="$(to_epoch "$STOP")"
step6=$((6 * 3600))

: > "$METEO_FILE"
: > "$SST_FILE"

for ((t=start_epoch; t<=stop_epoch; t+=step6)); do
  ts="$(fmt_time "$t")"
  yday="$(date -u -d "@$t" +%j)"
  hour="$(date -u -d "@$t" +%H)"
  awk -v ts="$ts" -v yday="$yday" -v hour="$hour" '
    BEGIN{
      pi=4.0*atan2(1.0,1.0);
      season=sin(2.0*pi*(yday-80.0)/365.0);
      diurnal=sin(2.0*pi*hour/24.0);
      u10=3.0 + 2.0*season + 1.5*diurnal;
      v10=1.0 + 1.0*cos(2.0*pi*(yday-30.0)/365.0);
      airp=1013.0 + 5.0*sin(2.0*pi*yday/14.0);
      airt=10.0 + 12.0*season + 4.0*diurnal;
      hum=70.0 - 10.0*diurnal + 10.0*(1.0-season);
      if (hum<40.0) hum=40.0;
      if (hum>98.0) hum=98.0;
      cloud=0.55 + 0.25*sin(2.0*pi*(yday+30.0)/365.0) - 0.15*diurnal;
      if (cloud<0.05) cloud=0.05;
      if (cloud>0.98) cloud=0.98;
      sst=11.0 + 8.0*season + 0.5*diurnal;
      printf "%s %8.3f %8.3f %7.2f %8.3f %8.3f %7.3f\n", ts, u10, v10, airp, airt, hum, cloud;
      printf "%s %8.3f\n", ts, sst >> "'"$SST_FILE"'";
    }' >> "$METEO_FILE"
done

# Daily vertical T/S profiles at 00:00 UTC, 10 points
: > "$TPROF_FILE"
: > "$SPROF_FILE"
for ((t=start_epoch; t<=stop_epoch; t+=86400)); do
  ts="$(fmt_time "$t")"
  yday="$(date -u -d "@$t" +%j)"
  awk -v ts="$ts" -v yday="$yday" '
    BEGIN{
      pi=4.0*atan2(1.0,1.0);
      season=sin(2.0*pi*(yday-80.0)/365.0);
      surf_t=11.0 + 10.0*season;
      bot_t=6.0 + 2.0*season;
      surf_s=31.5 + 1.0*sin(2.0*pi*(yday-120.0)/365.0);
      bot_s=33.5 + 0.3*sin(2.0*pi*(yday-150.0)/365.0);
      print ts " 10 2" >> "'"$TPROF_FILE"'";
      print ts " 10 2" >> "'"$SPROF_FILE"'";
      for (k=0; k<10; k++){
        z=-(5.0 + 10.0*k);
        tprof=bot_t + (surf_t-bot_t)*exp(z/20.0);
        sprof=bot_s - (bot_s-surf_s)*exp(z/25.0);
        printf " %6.1f %10.5f\n", z, tprof >> "'"$TPROF_FILE"'";
        printf " %6.1f %10.5f\n", z, sprof >> "'"$SPROF_FILE"'";
      }
    }'
done

# Hourly external pressure and zeta (semi-diurnal + diurnal tide-like signal)
: > "$EPRESS_FILE"
: > "$ZETA_FILE"
for ((t=start_epoch; t<=stop_epoch; t+=3600)); do
  ts="$(fmt_time "$t")"
  awk -v ts="$ts" -v t="$t" -v t0="$start_epoch" '
    BEGIN{
      pi=4.0*atan2(1.0,1.0);
      tau=t-t0;
      m2=2.0*pi*tau/44714.0;
      s2=2.0*pi*tau/43200.0;
      zeta=0.15*sin(m2) + 0.05*sin(s2);
      dpdx=1.0e-7*sin(m2);
      dpdy=1.0e-7*cos(m2);
      printf "%s %8.5f % .10e % .10e\n", ts, 1.0, dpdx, dpdy >> "'"$EPRESS_FILE"'";
      printf "%s % .8f\n", ts, zeta >> "'"$ZETA_FILE"'";
    }'
done

echo "Generated synthetic GOTM inputs in: $CASE_DIR"
echo "  - $(basename "$METEO_FILE")"
echo "  - $(basename "$SST_FILE")"
echo "  - $(basename "$TPROF_FILE")"
echo "  - $(basename "$SPROF_FILE")"
echo "  - $(basename "$EPRESS_FILE")"
echo "  - $(basename "$ZETA_FILE")"
