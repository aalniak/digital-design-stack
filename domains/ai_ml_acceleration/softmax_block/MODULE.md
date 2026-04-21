# Softmax Block

## Overview

Softmax Block converts a vector of logits into normalized probabilities or equivalent scaled scores by applying exponentiation and normalization over a defined reduction axis. It provides the probability-shaping stage used in attention and classifier heads.

## Domain Context

Softmax is the probability-normalization stage most often associated with attention and classification outputs. In accelerator stacks it is a numerically sensitive reduction-plus-elementwise operator that sits near decision boundaries, where exponent approximation, max subtraction, and normalization precision materially affect model behavior.

## Problem Solved

Softmax is deceptively simple at a mathematical level but difficult to implement robustly in hardware because exponentials, max subtraction, and reciprocal normalization must all be approximated consistently. A dedicated block makes those numeric and boundary assumptions explicit.

## Typical Use Cases

- Normalizing attention score rows before value weighting in transformer inference.
- Producing class probabilities from classifier logits.
- Supporting temperature-scaled or masked softmax variants in deployed models.
- Evaluating softmax approximation error versus hardware cost in accelerator prototypes.

## Interfaces and Signal-Level Behavior

- Inputs are logit vectors or score slices plus slice-boundary markers and optional mask or scale context.
- Outputs provide normalized values with valid signaling and slice-done status.
- Control interfaces configure reduction-axis length, mask policy, temperature or scale support, and numeric approximation mode.
- Status signals may expose slice_active, overflow, and normalization-underflow or divide-error conditions.

## Parameters and Configuration Knobs

- Maximum supported vector length or slice width.
- Input, accumulator, and output precision.
- Approximation method for exponent and reciprocal operations.
- Optional fused masking or temperature scaling support.

## Internal Architecture and Dataflow

The block usually contains max-reduction, shifted exponent approximation, sum reduction, reciprocal or normalization logic, and output scaling. The architectural contract should define whether outputs are true probabilities, quantized normalized values, or log-domain approximations, because downstream consumers often assume softmax semantics more strongly than the hardware actually guarantees.

## Clocking, Reset, and Timing Assumptions

The module assumes slice boundaries are explicit and masking semantics are aligned with the incoming tensor layout. Reset clears partial reduction state. If causal or padding masks are fused into the block, their precedence relative to scale or temperature must be documented clearly so model export tools can target it correctly.

## Latency, Throughput, and Resource Considerations

Softmax is reduction-limited and often latency-sensitive because a whole slice typically must be seen before normalized outputs are complete. Area is moderate, dominated by approximation and buffer resources. The key tradeoff is numerical fidelity versus throughput and buffering cost.

## Verification Strategy

- Compare outputs against a software softmax reference across varied vector sizes and value ranges.
- Stress large-magnitude logits, heavily masked rows, and nearly uniform score vectors.
- Verify output normalization and sum behavior within the documented numeric tolerance.
- Check approximation error and ordering stability on representative attention and classification workloads.

## Integration Notes and Dependencies

Softmax Block commonly follows Attention Score Unit or GEMM-based classifier heads and may feed Argmax/Top-k or value-weighted attention stages. It should align with Quantize/Dequantize policy so the surrounding pipeline knows whether softmax is performed in floating, fixed, or mixed precision.

## Edge Cases, Failure Modes, and Design Risks

- A numerically fragile softmax can destabilize attention even when earlier score computation is correct.
- Mask application order mistakes are especially dangerous in causal models.
- Quantized softmax outputs that are treated like full probabilities can mislead downstream postprocessing if their scaling is not explicit.

## Related Modules In This Domain

- attention_score_unit
- argmax_topk
- quantize_dequantize
- gemm_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Softmax Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
