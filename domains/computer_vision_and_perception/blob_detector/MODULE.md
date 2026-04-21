# Blob Detector

## Overview

The blob detector groups connected or locally salient image regions into candidate objects with area, centroid, and shape-like metadata. It is a common step between low-level masks and object-centric reasoning.

## Domain Context

Computer-vision and perception modules convert images and intermediate features into structured scene information such as edges, objects, motion, and geometry. In this domain the key documentation topics are coordinate conventions, feature representations, confidence semantics, latency through frame and track state, and how each block expects upstream preprocessing to have normalized the visual input.

## Problem Solved

Thresholded or foreground masks contain too much raw pixel detail for many downstream decisions. A blob detector condenses those masks into region-level measurements, but the exact connectivity and measurement semantics must be explicit. This module provides that condensation stage.

## Typical Use Cases

- Extracting candidate objects from foreground masks or segmentation maps.
- Computing region centroids and areas for tracking or counting.
- Providing reusable region-level abstraction in embedded vision pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts binary masks, saliency maps, or thresholded images with frame timing.
- Output side emits blob records, counts, and optional per-frame summary status.
- Control side configures minimum area, connectivity, and output-record format.

## Parameters and Configuration Knobs

- Image dimensions, connectivity mode, blob-record width, and area thresholds.
- Maximum number of blobs reported per frame and optional bounding-box or centroid outputs.
- Sorting policy and whether the block consumes binary or grayscale saliency.

## Internal Architecture and Dataflow

The detector analyzes the incoming mask to identify connected or locally coherent regions and then accumulates per-region measurements such as area, centroid, and extent. Some implementations pair tightly with connected-components labeling, while others use local peak logic for grayscale blobs. The documentation should state which model is implemented and how results are ordered when several blobs are found.

## Clocking, Reset, and Timing Assumptions

The input mask semantics and object polarity must already be defined upstream, because the detector does not infer what foreground means. Reset should clear any per-frame accumulation state cleanly.

## Latency, Throughput, and Resource Considerations

Blob detection can be moderate in memory and control complexity, especially at high resolutions or when many objects are present. Throughput is tied to frame rate, but output record bandwidth may spike on busy scenes.

## Verification Strategy

- Compare reported blob counts and measurements against a reference implementation on synthetic masks and recorded scenes.
- Check minimum-area filtering, output ordering, and maximum-blob truncation behavior.
- Verify frame-boundary resets and empty-scene handling.

## Integration Notes and Dependencies

This block often follows background subtraction or segmentation and feeds trackers or counters, so the record format and sorting semantics should be documented clearly. Integrators should also state whether partial frame buffering is acceptable or whether latency must remain strictly streaming.

## Edge Cases, Failure Modes, and Design Risks

- Connectivity assumptions can change the reported object count significantly.
- Output truncation on crowded scenes may hide detections unless status flags are surfaced.
- If foreground polarity is wrong, the detector may return large background blobs instead of objects.

## Related Modules In This Domain

- connected_components_labeler
- bounding_box_decoder
- kalman_tracker

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Blob Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
