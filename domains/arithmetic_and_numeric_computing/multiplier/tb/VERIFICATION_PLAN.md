# Multiplier Verification Plan

## Verification Goals

- Check unsigned full-product behavior.
- Check low-slice export and discarded-bit reporting.
- Check high-slice export and discarded-bit reporting.
- Check signed multiplication behavior.
- Check the selected slice matches the exact full product.

## Simulation Coverage

The first-pass simulation covers:

- unsigned full-width product export
- unsigned low-slice export with discarded bits
- unsigned high-slice export with discarded bits
- signed full-product behavior

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small signed low-slice instance:

- `product_out` matches the selected slice of the exact full product
- `discarded_nonzero` matches whether any omitted bits are high
