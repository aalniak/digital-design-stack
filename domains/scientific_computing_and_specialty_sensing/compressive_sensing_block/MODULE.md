# Compressive Sensing Block

## Overview

Compressive Sensing Block supports sparse-measurement acquisition or sparse-recovery processing for signals assumed to be sparse or compressible in a known basis. It provides a structured primitive for compressed measurement and reconstruction workflows.

## Domain Context

Compressive sensing is a measurement and reconstruction philosophy that exploits sparsity to recover signals from fewer observations than classical Nyquist-style acquisition might suggest. In this scientific domain the block usually supports either measurement generation or a reconstruction-oriented inner primitive for sparse inverse problems.

## Problem Solved

Sparse reconstruction workloads mix random or structured projections, basis assumptions, and iterative or thresholding style recovery steps that do not map neatly onto generic DSP blocks. A dedicated block makes the sparsity model and transform boundary explicit.

## Typical Use Cases

- Generating compressed measurements from high-dimensional sensor signals.
- Supporting sparse reconstruction experiments in imaging and spectroscopy.
- Reducing acquisition bandwidth in specialty sensing prototypes.
- Evaluating basis pursuit or thresholding style methods in hardware-oriented research.

## Interfaces and Signal-Level Behavior

- Inputs may include raw signal vectors, sensing matrices or projection patterns, and reconstruction-control metadata depending on the supported role.
- Outputs provide compressed measurements, sparse coefficient estimates, or iterative update terms.
- Control interfaces configure measurement dimension, basis or dictionary selection, and operating mode.
- Status signals may expose iteration_done, sparsity_violation, and convergence or conditioning warnings.

## Parameters and Configuration Knobs

- Signal dimension and compressed measurement dimension.
- Supported sensing-pattern source and basis representation.
- Measurement-only versus reconstruction-assist operating mode.
- Numeric precision for coefficients, residuals, and thresholds.

## Internal Architecture and Dataflow

The block often combines projection or transform arithmetic, sparse-thresholding support, and iterative control or sideband interaction with a host solver. The key contract is whether it performs actual reconstruction, only compressive measurement, or one inner step of a larger sparse solver, because those are very different integration points.

## Clocking, Reset, and Timing Assumptions

The module assumes the target signal is sparse or compressible in the configured basis and that the chosen sensing or recovery method is appropriate for the application. Reset clears iterative state and residual history. If randomness enters the sensing matrix or reconstruction path, its source and reproducibility assumptions should be documented.

## Latency, Throughput, and Resource Considerations

Performance depends on matrix dimensions, sparsity level, and whether the block does measurement only or iterative recovery. The tradeoff is between hardware specialization for one sparse model and generality across many reconstruction problems. Throughput matters less than clear convergence and numerical contracts.

## Verification Strategy

- Compare compressed measurements or recovered coefficients against a software sparse-sensing reference.
- Stress dense or poorly sparse inputs to verify failure or reduced-quality signaling.
- Check basis and sensing-pattern interpretation explicitly.
- Run end-to-end reconstruction experiments on representative scientific datasets rather than toy vectors only.

## Integration Notes and Dependencies

Compressive Sensing Block often works with Matrix Multiply Engine, Monte Carlo RNG, and specialty sensor front ends such as Hyperspectral Cube Unpacker. It should align with host reconstruction tooling on basis choice and whether hardware outputs are final estimates or intermediate iterations.

## Edge Cases, Failure Modes, and Design Risks

- Sparse-recovery blocks are easy to oversell; many are only partial solvers, not full reconstruction engines.
- A mismatch in basis or sensing-pattern interpretation can make outputs useless while still looking numerically active.
- Convergence or quality claims must be tied to the actual supported problem family, not generic compressive-sensing theory.

## Related Modules In This Domain

- matrix_multiply_engine
- monte_carlo_rng
- hyperspectral_cube_unpacker
- spectral_calibration_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Compressive Sensing Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
