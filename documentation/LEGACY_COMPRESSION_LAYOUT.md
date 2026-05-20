# Legacy Compression Layout

Generated: 2026-05-16 13:12:11 

The SLATE package previously exposed both loose HP-UX-era encoded files and
multiple decoded sidecar directories. That was accurate as an audit trail, but
it was a poor reader-facing GitHub layout.

The package now uses this layout:

- `data/decoded_model_outputs/`: primary reader-facing decoded outputs.
- `data/legacy_encoded_originals/legacy_encoded_originals_20260516.zip`: compact archive of the original encoded files, preserved for provenance and future decoder improvement.
- `LEGACY_Z_DECODE_MANIFEST.csv`: authoritative decode manifest copied from the 2026-05-16 decoder run.
- `LEGACY_ENCODED_ORIGINALS_MANIFEST.csv`: maps every moved encoded file to its archive member and decoded output if one exists.

Counts:

- Encoded originals moved into the archive: 146
- Decoded primary outputs retained: 120
- Complete decodes: 15
- Partial decodes: 105
- Failed decodes retained only as encoded originals: 26
- Superseded loose decode/audit paths removed: 5

Interpretation:

- Future users should start with `decoded_model_outputs/`.
- The encoded archive is not the working surface; it is a provenance and recovery object.
- `partial` decoded files may be useful but should be treated cautiously because the decoder did not verify a clean end-of-file/length condition.
- `failed` files were not decoded and remain available inside the encoded-originals ZIP for later decoder work.
