# Verification Environment Status

## Summary

- Generated: 2026-04-21 17:37:34 +03:00
- Workspace: `C:\digital_design_stack`
- Detected toolchain root: `C:\Users\arda\tools\oss-cad-suite\oss-cad-suite`
- Overall status: `READY`
- Recommended invocation: `powershell -ExecutionPolicy Bypass -File .\\scripts\\check_verification_environment.ps1`

## Why This Matters

The module library is being shaped around highly configurable IP blocks. That means verification has to cover more than one fixed instantiation. The environment is only considered ready when it can elaborate configurable RTL, run a simulation smoke test, execute a synthesis sanity check, and complete a basic formal proof.

## Tool Status

| Tool | Status | Details |
| --- | --- | --- |
| iverilog | PASS | Icarus Verilog version 14.0 (devel) (s20251012-146-gbf7eb2cac-dirty) (`C:\Users\arda\tools\oss-cad-suite\oss-cad-suite\bin\iverilog.exe`) |
| vvp | PASS | Icarus Verilog runtime version 14.0 (devel) (s20251012-146-gbf7eb2cac-dirty) (`C:\Users\arda\tools\oss-cad-suite\oss-cad-suite\bin\vvp.exe`) |
| yosys | PASS | Yosys 0.63+188 (git sha1 cede13a74-dirty, x86_64-w64-mingw32-g++ 13.2.1 -O3) (`C:\Users\arda\tools\oss-cad-suite\oss-cad-suite\bin\yosys.exe`) |
| sby | PASS | SBY v0.63-11-g6424d15 (`C:\Users\arda\tools\oss-cad-suite\oss-cad-suite\bin\sby.exe`) |
| verilator | PASS | Verilator 5.047 devel rev v5.046-211-gdbd482332 (mod) (`C:\Users\arda\tools\oss-cad-suite\oss-cad-suite\bin\verilator_bin.exe`) |
| python | PASS | Python 3.11.6 (`C:\Users\arda\tools\oss-cad-suite\oss-cad-suite\lib\python3.exe`) |
| z3 | PASS | Z3 version 4.15.5 - 64 bit (`C:\Users\arda\tools\oss-cad-suite\oss-cad-suite\bin\z3.exe`) |
| gtkwave | PASS | Present but not launched in the headless environment (`C:\Users\arda\tools\oss-cad-suite\oss-cad-suite\bin\gtkwave.exe`). |

## Smoke Checks

| Check | Status | Details |
| --- | --- | --- |
| simulation_smoke | PASS | SMOKE_SIM_PASS count=5 |
| synthesis_smoke | PASS | 10 wire bits |
| formal_smoke | PASS | SBY 17:37:33 [C:\digital_design_stack\verification\out\smoke_runs\smoke_formal] DONE (PASS, rc=0) |

## Notes

- The local machine does not expose the OSS CAD Suite tools on the default `PATH`, so verification scripts should activate the suite environment explicitly rather than relying on ambient shell state.
- On this Windows installation, `verilator_bin.exe` is the directly invokable Verilator entry point.
- The repository verification scripts intentionally avoid updating the OSS CAD Suite GTK cache because that would require writes into the tool installation directory and is not needed for headless RTL verification.
- `gtkwave` is present for waveform inspection, but it is not launched by the automated environment check because that path is GUI-only.

## Current Readiness

Simulation, synthesis, and formal smoke checks all pass under the detected OSS CAD Suite installation. This is enough to begin scaffolding per-module `rtl/`, `tb/`, and `spec/` directories and to start adding module-level verification assets incrementally.
