#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 4 ]]; then
  echo "Usage: $0 <case_dir> <casename> [timeout_sec] [logfile]" >&2
  exit 2
fi

CASE_DIR="$1"
CASENAME="$2"
TIMEOUT_SEC="${3:-1800}"
LOGFILE="${4:-run_np1_${CASENAME}.log}"

FVCOM_BIN="/home/tetsunori/ocean_models/external/FVCOM/src/fvcom"
MPIRUN_BIN="/opt/intel/oneapi/mpi/2021.17/bin/mpirun"

cd "$CASE_DIR"

echo "[run-fvcom-np1] case_dir=$CASE_DIR casename=$CASENAME timeout=${TIMEOUT_SEC}s log=$LOGFILE"
timeout "${TIMEOUT_SEC}s" \
  env I_MPI_FABRICS=shm FI_PROVIDER=tcp \
  "$MPIRUN_BIN" -np 1 "$FVCOM_BIN" --casename="$CASENAME" \
  > "$LOGFILE" 2>&1
rc=$?

echo "[run-fvcom-np1] EXIT:$rc"
exit "$rc"
