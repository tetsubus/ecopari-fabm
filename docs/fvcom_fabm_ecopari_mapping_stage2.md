# Stage 2 Mapping: FVCOM -> FABM -> EcoPARI

This document defines the variable mapping needed to move from Stage 1 (GOTM) to Stage 2 (FVCOM coupling).

## Current EcoPARI-FABM dependency status (as implemented)

Code references:

1. `fabm/src/models/ecopari/ecopari_model_library.F90`
2. `fabm/src/models/ecopari/lt_eco_fabm_adapter.f90`

Currently registered FABM dependencies in EcoPARI model:

1. `standard_variables%temperature`
2. `standard_variables%practical_salinity`
3. `standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux` (only when `use_host_kext: true`)

Current temporary behavior:

1. `kext` is no longer hardcoded in source. It is now controlled by FABM parameters:
   - `use_host_kext: false` + `kext_default: 0.2` (default)
   - `use_host_kext: true` to read host-provided attenuation
2. Single-column wrapper assumptions are still active (`ncube=1,mx=1,my=1`) for the current Stage 1 adapter path.

## Mapping table (to be implemented for FVCOM host coupling)

| Priority | EcoPARI use | FABM variable (target) | Unit (expected) | FVCOM source candidate | Status |
|---|---|---|---|---|---|
| P0 | Water temperature | `standard_variables%temperature` | degC (or FABM host unit) | 3D temperature field | Implemented in model, host wiring pending |
| P0 | Salinity | `standard_variables%practical_salinity` | PSU | 3D salinity field | Implemented in model, host wiring pending |
| P0 | Light attenuation / extinction | `standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux` or `kext_default` parameter | 1/m | from FVCOM optics/turbidity/chl or prescribed field | Parameter path implemented; host wiring pending |
| P1 | Surface shortwave (if moving to physically consistent PAR path) | `standard_variables%surface_downwelling_shortwave_flux` (or equivalent) | W/m2 | FVCOM surface radiation forcing | Not connected |
| P1 | Wind speed / stress (if EcoPARI weather pathway is host-driven) | FABM standard/horizontal variable as available | m/s or Pa | FVCOM met forcing / stress | Not connected |
| P1 | Air pressure (optional; currently adapter default) | scalar dependency (host-provided) | Pa | FVCOM met forcing | Not connected |

Notes:

1. P0 items are minimum to run with meaningful tracer dynamics.
2. P1 items are recommended to remove hardcoded defaults and improve physical consistency.

## Required host-side tasks for FVCOM

1. Expose 3D temperature and salinity fields to FABM at each biogeochemical call.
2. Decide `kext` strategy:
   - Option A: keep fixed constant initially (quick integration).
   - Option B: provide dynamic field from FVCOM diagnostics/forcing (recommended for production).
3. Confirm unit compatibility between FVCOM fields and FABM expectations.
4. Validate MPI consistency (1, 2, 4 ranks) with identical setup.

Current bridge-side controls (`BIOLOGICAL_MODEL_FILE`, optional):

1. `FABM_KEXT_SOURCE`:
   - `1`: derive from `RHEAT/ZETA1/ZETA2` (default, existing FVCOM optics path)
   - `2`: use `FABM_KEXT_CONST`
   - `3`: use `ATANU_W`
2. `FABM_KEXT_CONST`: constant attenuation [1/m] when source=2
3. `FABM_KEXT_MIN`, `FABM_KEXT_MAX`: clamp range [1/m]

## Confirmed FVCOM biology hook points (from `external/FVCOM`)

1. Activation switches in namelist:
   - `src/mod_main.F`: `BIOLOGICAL_MODEL`, `BIOLOGICAL_MODEL_FILE`, `STARTUP_BIO_TYPE`
   - `src/mod_input.F`: defaults for these switches
2. Startup and parameter loading:
   - `src/fvcom.F`: `IF(BIOLOGICAL_MODEL) CALL GET_PARAMETER_NEW(...)`
   - `src/mod_startup.F`: startup path (`BIO_INITIAL`, `READ_BIO`, `SET_OBSERVED_BIO`)
3. Time-step biology source update:
   - `src/internal_step.F`: `IF(BIOLOGICAL_MODEL) CALL BIO_3D1D`
   - `src/mod_bio_3D.F`: `SUBROUTINE BIO_3D1D` (current online biology entrypoint)

Implementation implication:

1. Stage 2 should introduce FABM-EcoPARI coupling behind the same `BIOLOGICAL_MODEL` guard first.
2. Replace/branch inside `BIO_3D1D` path with FABM source-term evaluation while preserving existing startup/restart controls.

Current code status:

1. `external/FVCOM/src/mod_bio_3D.F` now has a compile-time hook:
   - `USE_FABM_ECOPARI_BRIDGE` (via `FABM_ECOPARI_BRIDGE` + `HAVE_LT_ECO_WRAPPER` macros)
2. Default build behavior is unchanged (legacy biology path).
3. When both macros are enabled, call path enters `BIO_3D1D_FABM_BRIDGE` and calls `LT_ECO_SCPELG_FABM`.
4. Current minimum bridge implementation:
   - maps `BIO_ALL(I,1,1:NTT)` + `T1(I,1)` + `S1(I,1)` to EcoPARI wrapper
   - applies Euler update to `BIO_ALL(I,1,1:NTT)` only
   - falls back to legacy biology if wrapper returns non-zero error
5. `external/FVCOM/src/lt_eco_fabm_adapter_stub.F` now includes strict shape guards for
   `ncube=1,mx=1,my=1`, `mz>=1`, and `size(scpl_out)==size(ccpl_in)` to prevent invalid memory paths.

## Current verified runtime status (2026-02-20)

1. Build: `external/FVCOM/src` release build succeeds with
   `-DBioGen -DFABM_ECOPARI_BRIDGE -DHAVE_LT_ECO_WRAPPER`.
2. Case: `cases/nns_annual` finishes with `EXIT:0` and `TADA!`.
3. Log reference:
   - `cases/nns_annual/fvcom_casecheck_stubsafe.out`
4. No `SIGSEGV` or `free(): invalid pointer` observed in this verified run.

Historical note:

1. The above limitation applied to the earlier `fvcom_casecheck_stubsafe.out` phase only.

## Updated coupling status (2026-02-20, later)

1. FABM/EcoPARI was rebuilt with GNU Fortran (`mpif90`) at:
   - `fabm/build_gfortran`
2. FVCOM build was linked against this `libfabm` and EcoPARI module includes by updating:
   - `external/FVCOM/src/make.inc`
3. FVCOM adapter source was switched from safety stub to real adapter implementation:
   - `external/FVCOM/src/lt_eco_fabm_adapter_stub.F`
4. Symbol check confirms both wrapper and EcoPARI kernel are present in FVCOM binary:
   - `__lt_eco_fabm_adapter_MOD_lt_eco_scpelg_fabm`
   - `lt_eco_scpelg_`
5. Runtime check still completes successfully:
   - `cases/nns_annual/fvcom_casecheck_realadapter1.out`

Result:

1. The current binary no longer depends on the stage-1 error-return stub behavior.
2. The call path can resolve into the EcoPARI kernel symbol at runtime without segmentation fault in this case.

Enable notes (FVCOM classic make):

1. `external/FVCOM/src/make.inc` enables cpp flags via `FLAG_*` entries (`CPPARGS`).
2. To activate this bridge path, add two flags in `make.inc`:
   - `-DFABM_ECOPARI_BRIDGE`
   - `-DHAVE_LT_ECO_WRAPPER`
3. Keep `-DBioGen` enabled as usual; without `BioGen`, `mod_bio_3D.F` path is not compiled.

## Integration milestones

1. **Milestone S2-1 (minimum coupling)**
   - FVCOM provides temperature and salinity to FABM.
   - EcoPARI runs without crash for short case.
2. **Milestone S2-2 (remove hardcoded optics)**
   - Replace fixed `kext=0.2` with host-provided field or configured parameter.
   - Current status: hardcoded value removed; parameterized fallback implemented; FVCOM host field wiring remains.
3. **Milestone S2-3 (stability and reproducibility)**
   - Multi-rank reproducibility checks.
   - Restart consistency checks.

## Acceptance checks (Stage 2)

1. Short FVCOM run finishes in release build without SIGSEGV/FPE.
2. No NaN in EcoPARI state variables.
3. Same setup on 1 vs 2 ranks shows acceptable numerical consistency.
4. Restarted run continues from checkpoint without discontinuity.
