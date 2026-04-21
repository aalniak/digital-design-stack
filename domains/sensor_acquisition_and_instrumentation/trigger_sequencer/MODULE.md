# Trigger Sequencer

## Overview

The trigger sequencer manages when acquisition or measurement actions start, stop, arm, and advance through scripted trigger states. It is the control-plane heart of many instruments and capture workflows.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

Complex measurements often require more than a single level trigger. They need arming, pretrigger capture, holdoff, multi-step sequences, and clear status reporting. This module provides that structured trigger control instead of scattering it across custom state machines.

## Typical Use Cases

- Arming and firing acquisition systems based on level, edge, or event conditions.
- Managing multi-step instrument capture workflows with holdoff and rearm behavior.
- Providing reusable trigger control for oscilloscopes, loggers, and sensor test rigs.

## Interfaces and Signal-Level Behavior

- Trigger-input side receives threshold hits, external triggers, software triggers, or event-detector outputs.
- Control side configures sequencing rules, holdoff, pretrigger depth, arm state, and rearm policy.
- Output side emits capture-start, capture-stop, armed-state, and sequence-status signals to data-path modules.

## Parameters and Configuration Knobs

- Number of trigger states, holdoff counters, pretrigger depth, and source-select width.
- External versus software trigger support and one-shot versus retriggerable behavior.
- Status visibility and timeout or auto-rearm options.

## Internal Architecture and Dataflow

The sequencer is usually a state machine that waits in an armed state, evaluates trigger sources against configured rules, and then issues control outputs to acquisition blocks when the trigger condition sequence is satisfied. Richer variants also manage pretrigger buffering, posttrigger length, and timeout behavior. The documentation should define exactly what causes a trigger to be considered consumed and when the system becomes armed again.

## Clocking, Reset, and Timing Assumptions

The timing relationship between trigger outputs and the data path must be explicit, especially when pretrigger memory is involved. Reset should return the machine to a known unarmed or armed state according to the intended instrument behavior.

## Latency, Throughput, and Resource Considerations

Trigger sequencing is low-rate control logic, but it sits on the critical observability path of measurement systems. Its value is in deterministic orchestration, not datapath speed.

## Verification Strategy

- Check arming, firing, holdoff, timeout, and rearm behavior against scripted trigger scenarios.
- Verify interactions with pretrigger and posttrigger capture windows.
- Confirm software-trigger and external-trigger paths obey the same state-machine contract where intended.

## Integration Notes and Dependencies

This block is meaningful only with the acquisition modules it controls, so trigger timing and buffer ownership should be documented together. Integrators should also preserve user-facing semantics such as what it means for the instrument to be armed, triggered, or done.

## Edge Cases, Failure Modes, and Design Risks

- Small state-machine ambiguities can make instruments behave differently from what operators expect.
- If trigger timing relative to sample capture is vague, pretrigger and posttrigger records may be misinterpreted.
- Auto-rearm policy can create double captures or missed events if not explicit.

## Related Modules In This Domain

- event_detector
- threshold_detector
- sample_packer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Trigger Sequencer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
