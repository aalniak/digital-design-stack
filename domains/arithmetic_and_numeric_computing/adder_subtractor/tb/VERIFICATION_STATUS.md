# Adder Subtractor Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_adder_subtractor_verification.ps1`

## Verified Behaviors

- unsigned addition result generation
- addition carry-in propagation and carry-out reporting
- subtraction result generation and no-borrow indication
- signed positive overflow and signed subtract overflow flag behavior
- zero and negative flag reporting
- exact combinational result equivalence for the verified formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no subtraction borrow-in chaining yet
- no randomized operand sweep bench yet
- no pipelined or registered output variant yet
