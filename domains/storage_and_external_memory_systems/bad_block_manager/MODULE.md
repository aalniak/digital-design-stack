# Bad Block Manager

## Overview

The bad block manager tracks unusable erase blocks and redirects allocation away from them so higher storage layers can treat NAND-like media as a mostly contiguous logical space. It is a reliability and lifecycle-management block rather than a high-throughput datapath primitive.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

Raw flash media inevitably contains factory-marked bad blocks and may accumulate new failures over time. If that information is not centralized, logical-to-physical mapping becomes inconsistent and data may be placed into unreliable regions. This module records bad-block knowledge and exposes safe allocation decisions to flash-control logic.

## Typical Use Cases

- Managing factory and runtime bad blocks in raw NAND flash systems.
- Supporting wear-leveling or logical block translation layers that need a trusted health map.
- Preventing boot images or metadata from being placed in fragile erase blocks.

## Interfaces and Signal-Level Behavior

- Management side reads factory markers, runtime test results, or ECC failure notifications and updates the bad-block table.
- Allocation side answers whether a candidate block is usable and may suggest the next available replacement block.
- Status and maintenance interfaces expose counts, table snapshots, and optional persistent metadata storage hooks.

## Parameters and Configuration Knobs

- Maximum number of tracked blocks, storage method for bad-block metadata, and replacement-search policy.
- Support for dynamic bad-block retirement, reserved-block pools, and mirrored metadata copies.
- Address width and whether the module manages one die, one plane, or a larger aggregate space.

## Internal Architecture and Dataflow

The manager typically stores a table or bitmap of unusable blocks, updates that structure from scan results and runtime failures, and offers lookup helpers to allocation or translation layers. More advanced versions also maintain reserved pools for remapping critical metadata or boot regions. Since write and erase operations happen slowly, correctness and persistence matter more than raw combinational speed.

## Clocking, Reset, and Timing Assumptions

Some flash devices expose factory bad-block markers in device-specific locations, so the interface contract should say who interprets raw metadata and when the manager becomes authoritative. Reset must not lose runtime-retired block information unless there is a deliberate rebuild or rescan process.

## Latency, Throughput, and Resource Considerations

Lookup cost is usually tiny compared with flash access latency. Resource use depends on how many blocks are tracked and whether the table is kept in SRAM, ROM-backed metadata, or external persistent storage.

## Verification Strategy

- Verify correct handling of factory-marked bad blocks, runtime retirements, and replacement search.
- Check table persistence or rebuild sequencing across reset and power-fail recovery scenarios.
- Exercise exhaustion of spare blocks so higher layers receive explicit failure rather than looping indefinitely.

## Integration Notes and Dependencies

This block sits beside NAND controllers, ECC failure monitors, and mapping layers. Integration should define who decides a block has become bad, how quickly that decision becomes permanent, and whether software can override or inspect the retirement map.

## Edge Cases, Failure Modes, and Design Risks

- If runtime ECC failures are not plumbed into the bad-block manager, the system may keep using degrading media.
- Metadata persistence bugs can resurrect retired blocks after reboot.
- Overly aggressive retirement policy can waste media life, while timid policy can lose data.

## Related Modules In This Domain

- nand_flash_controller
- flash_ecc_block
- writeback_cache

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Bad Block Manager module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
