# Embedding Lookup

## Overview

Embedding Lookup retrieves dense vector representations for input token or category indices and emits those vectors in the tensor format expected by later compute stages. It provides the table-lookup front end for discrete-input models.

## Domain Context

Embedding lookup replaces sparse token or ID inputs with dense learned vectors in language models, recommendation systems, and many categorical-feature pipelines. In an accelerator stack it is the sparse-to-dense bridge that often stresses memory more than arithmetic.

## Problem Solved

Sparse IDs are not directly usable by neural compute arrays, and embedding tables are often large enough that memory layout, bandwidth, and caching dominate behavior. A dedicated lookup block keeps those concerns explicit instead of treating embeddings as just another matrix multiply.

## Typical Use Cases

- Fetching token embeddings for transformer inference.
- Mapping categorical features into dense vectors in recommendation or ranking pipelines.
- Applying optional position or segment embedding composition in sequence models.
- Reducing host overhead for repeated indexed memory reads into large parameter tables.

## Interfaces and Signal-Level Behavior

- Inputs are token or category indices plus sequence boundaries and optional embedding-table selectors.
- Outputs provide embedding vectors, valid signaling, and optional composition with auxiliary embeddings.
- Control interfaces configure table base, vector width, padding or unknown-token policy, and optional quantization mode.
- Status signals may expose index_out_of_range, table_miss, and sequence_done conditions.

## Parameters and Configuration Knobs

- Embedding dimension and table depth.
- Index width and supported batch or sequence parallelism.
- Optional fused addition of positional or segment embeddings.
- Parameter precision and storage layout, such as row-major packed vectors or compressed forms.

## Internal Architecture and Dataflow

The module generally contains address generation, SRAM or DMA-backed vector fetch, optional multi-table combination, and output packing into the downstream tensor layout. The key contract is whether vectors are fetched exactly as stored or transformed by quantization, dequantization, or composition logic before emission.

## Clocking, Reset, and Timing Assumptions

The block assumes indices are valid for the active vocabulary or that out-of-range behavior is explicitly configured. Reset clears outstanding fetch context. If embeddings reside in external memory, the latency model and required prefetch behavior should be clear so downstream pipelines know whether backpressure is normal or exceptional.

## Latency, Throughput, and Resource Considerations

Embedding lookup is often memory-bound, with throughput determined by table locality, cache strategy, and sequence length. The tradeoff is usually between on-chip storage for hot rows and wider external-memory bandwidth. Arithmetic cost is low compared with the burden of moving dense vectors efficiently.

## Verification Strategy

- Check returned vectors and optional composed outputs against a software lookup reference for several tables and index patterns.
- Stress repeated indices, out-of-range indices, and long sequences.
- Verify output packing and sequence-boundary signaling.
- Measure behavior under external-memory latency or cache-miss scenarios if applicable.

## Integration Notes and Dependencies

Embedding Lookup typically feeds GEMM or attention pipelines and depends heavily on Tensor DMA and parameter-layout tooling. It should align with model compiler assumptions about vocabulary order, special tokens, and any fused positional encoding policy.

## Edge Cases, Failure Modes, and Design Risks

- A vocabulary-order mismatch can corrupt every downstream result while leaving tensor shapes apparently correct.
- Memory-latency assumptions are easy to underestimate, causing the rest of the pipeline to starve.
- Implicit padding or unknown-token substitution can hide data-quality problems if not surfaced clearly.

## Related Modules In This Domain

- gemm_engine
- tensor_dma
- qkv_projection_helper
- quantize_dequantize

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Embedding Lookup module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
