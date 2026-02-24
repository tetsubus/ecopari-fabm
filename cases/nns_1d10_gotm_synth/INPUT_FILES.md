# GOTM-FABM-EcoPARI (10 layers) Synthetic Input Set

This case is configured in:

- `gotm.yaml`
- `fabm.yaml`
- `ecosystem.dat`
- `sysin`

## Required input files used by current `gotm.yaml`

1. `meteo_sine_1y.dat`
- Columns: `time u10 v10 airp_hPa airt_C rel_humidity_percent cloud_fraction`
- Used for wind, air pressure, air temperature, humidity, cloud cover.

2. `sst_sine_1y.dat`
- Columns: `time sst_C`
- Used as observed surface temperature input.

3. `t_prof_sine_1y.dat`
- Record header: `time npoints 2`
- Followed by `npoints` rows: `z_m temperature_C`.

4. `s_prof_sine_1y.dat`
- Record header: `time npoints 2`
- Followed by `npoints` rows: `z_m salinity_psu`.

5. `ext_press_sine_1y.dat`
- Columns: `time h_m dpdx dpdy`
- Used by `mimic_3d.ext_pressure` (`dpdx`, `dpdy`, and `h`).

6. `zeta_sine_1y.dat`
- Columns: `time zeta_m`
- Used by `mimic_3d.zeta` (`method: file`).

## Optional/supporting files in this setup

- `fabm.yaml`: enables FABM and selects `ecopari/pelagic`.
- `ecosystem.dat`: EcoPARI parameter set.
- `sysin`: EcoPARI side configuration used by the coupled setup.

## Regeneration

Synthetic files can be regenerated with:

```bash
/home/tetsunori/ocean_models/scripts/generate-gotm-synthetic-inputs.sh \
  /home/tetsunori/ocean_models/cases/nns_1d10_gotm_synth \
  "1998-01-01 00:00:00" \
  "1999-01-01 00:00:00"
```

