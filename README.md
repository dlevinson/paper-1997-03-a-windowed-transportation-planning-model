# A Windowed Transportation Planning Model

## Bibliographic Information

- Row ID: `paper-1997-03`
- Year: 1997
- Authors: David M. Levinson and Yuanlin Huang
- Venue: Transportation Research Record 1607:45-54 (1997)
- DOI: https://doi.org/10.3141/1607-07
- Citation: Levinson, David M., and Yuanlin Huang. (1997). "Windowed Transportation Planning Model." Transportation Research Record 1607:45-54. https://doi.org/10.3141/1607-07

## Archive Status

- Pipeline: `READY-TO-UPLOAD/PUBLIC`
- Package status: `ready_to_package_review`
- Upload action: `upload_candidate`
- Rights status: `likely_clear_with_provenance`
- Human subjects status: `no`
- Updated: 2026-05-17 06:13:07 AEST

## Paper Evidence

The paper describes SLATE, the System for Local Area Traffic Estimation, applied to the north Bethesda window in Montgomery County. It states that SLATE used Travel/2 regional model inputs, EMME/2, block-level census land use, tax-assessor commercial and future residential land-use data, detailed networks/intersections, calibration against traffic counts, and additional programs written by the authors.

## Package Boundary

The local package now contains the corresponding north Bethesda SLATE model setup, SLATE source/macros, paper-specific SLATE Travel/2 macro files, decoded model-output sidecars where possible, preserved encoded originals, convergence/model notes, and scanned SLATE context reports. Drafts, letters, recommendations, and broad duplicate Travel/2 dependency trees are excluded or represented by shared-source pointers.

This is an archival package, not a modern standalone reproduction script. Re-execution would require compatible EMME/2 and Travel/2-era dependencies, plus interpretation of legacy model files. The package keeps source/model materials and decoded sidecars rather than pretending to be a turnkey modern runtime.

See `PAPER_FIRST_VALIDATION.md` for the paper-to-package evidence check.

## Contents

- `paper/`: final published paper reference copy.
- `model_setup/bethesda_slate/`: north Bethesda SLATE model setup and EMME/2 model files.
- `code/slate_driver_scripts/`: SLATE shell driver script copied from the M-NCPPC source archive.
- `code/slate_emme2_macros/`: SLATE EMME/2 macro/source files.
- `code/slate_travel2_macros/`: paper-specific SLATE Travel/2 macro files.
- `data/decoded_model_outputs/`: 121 decoded model-output sidecars where legacy `.Z`/`.z` decoding succeeded or partially succeeded.
- `data/legacy_encoded_originals/`: ZIP preserving the 146 original encoded HP-UX files once; no loose encoded originals are retained in `model_setup/`.
- `documentation/`: source review, manifests, scanned SLATE context reports, convergence/model notes, and shared-source pointers.

## Shared Dependencies

The full shared Travel/2 macro source is not duplicated here. Use `/Users/dlev2617/Documents/Code/Agents/github-packages/_shared_sources/mncppc-travel2-source/mncppc_sourcecode_t2macros` as the shared source package.

<!-- package-hardening-status:start -->
## Package Hardening Status

Generated: 2026-05-20 14:46:37 AEST

- Pipeline: `READY-TO-UPLOAD/PUBLIC`
- Sidecars added/updated: `PACKAGE_STATUS.md`, `PACKAGE_MANIFEST.csv`, `LICENSE_STATUS.md`.
- Paper reference copies are for local audit convenience and are not public-upload assets without rights review.
- Final GitHub upload should use the manifest include statuses and the license-status note.
<!-- package-hardening-status:end -->
