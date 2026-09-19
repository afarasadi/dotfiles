---
name: logo-to-swiftui-draw
description: Convert a logo image (PNG) into a clean SwiftUI Shape and a component that traces its outline before revealing the fill for splash screens, loading states, and hero animations. Use when the user asks to draw, animate, vectorize, or trace a logo, or requests a SwiftUI logo animation.
---

# logo-to-swiftui-draw

## Principle

A traced logo only looks good when its `Path` is **clean**: use a small number of
primitives, avoid self-intersections, and order subpaths as a pen would draw them.
Automatic vectorization with potrace can be faithful but often produces too many nodes.
For geometric logos, reconstructing the shape with primitives and **measuring fidelity**
against the source image is more reliable than trusting visual inspection alone.

The animation component is generic (`LogoDraw<S: Shape>`, in
`Sources/LogoDraw/LogoDraw.swift` in this repository). The job of this skill is to produce
the `Shape`.

## Prerequisites

- macOS with Xcode. `swiftc` and SwiftUI's `ImageRenderer` can render without a simulator.
- Python 3 with `numpy`, `pillow`, and `scipy`.
- For path B (organic logos): `brew install potrace`.

The scripts are in this skill's `scripts/` directory. Run all commands from a temporary
working directory.

## Workflow

### Step 0 - Classify the logo

Open the image and decide:

- **Geometric** (constant-width strokes, circles, rounded corners, and straight lines):
  use path A. Examples include pictograms, monograms, and flat symbols.
- **Organic** (lettering, freeform shapes, or variable widths): use path B.

When uncertain, start with path A and measure it. If a small set of primitives cannot reach
roughly 0.90 IoU, the logo is not geometric enough for that approach.

### Step 1 - Measure both paths

```sh
python3 scripts/measure.py logo.png --mask mask.png
```

The output contains the image size and connected components with bounding boxes. Inspect
`mask.png`: the threshold must isolate only the glyph (use `--threshold` or `--dark`). If
the image contains a wordmark or a bright background, record a `y` value below which pixels
should be ignored with `--ignore-below`.

Take row and column runs for each component:

```sh
python3 scripts/measure.py logo.png --rows 520 720 6
python3 scripts/measure.py logo.png --cols 400 700 12
```

Derive measurements rather than guessing: stroke width (horizontal width multiplied by the
sine of the angle), line angles (the `dx/dy` change between rows), centers and radii of round
ends (extreme point plus half the stroke width), and the transition from a line to a curve.

### Step 2A - Model geometric logos with primitives

Copy `scripts/models/runner.py` as a starting point. A model contains:

- `PARAMS`: a dictionary of measured widths, centers, angles, and radii;
- `build(P)`: a list of polygons, **one per subpath**, built from `fillet`, `arc`, and lines;
- `STEPS` and `VEC_STEPS`: the search step for each parameter.

Rules that prevent rework:

- Build **explicit contours**, not `strokedPath`. Explicit contours control the start point
  and avoid self-intersections when a curve radius is less than half the stroke width.
- The outer and inner corners of a stroke are not always concentric in hand-drawn or
  AI-generated logos. Measure both radii separately.
- Subpath order is animation order. Start with the largest piece and finish with the detail.

Measure and tune:

```sh
python3 scripts/tune.py logo.png models/my_logo.py                 # IoU + overlay.png
python3 scripts/tune.py logo.png models/my_logo.py --tune          # coordinate descent -> params.json
```

Read `overlay.png`: red is where the model extends beyond the source and green is where the
source is missing from the model. Adjust the construction, not only the numbers, until the
remaining error is mostly antialiasing and the source image's edge noise.

### Step 2B - Vectorize organic logos

```sh
potrace mask.pbm -s -o logo.svg --turdsize 20 --alphamax 1 --opttolerance 0.4
```

Generate the `.pbm` from `mask.png` with Pillow. If the resulting path has too many nodes,
simplify it in Figma or Illustrator and export it again. Convert the SVG `d` data into a
SwiftUI `Path` using `move`, `line`, `cubic`, and `close`. The component is the same either
way; trace quality depends on having a manageable number of nodes and a sensible drawing
direction.

### Step 3 - Port to SwiftUI

Create `MyLogoShape.swift` following `Sources/LogoDraw/RunnerLogoShape.swift`:

- Set `designSize` to the glyph bounding box in the source image. In `path(in:)`, calculate
  `scale = min(rect.width / W, rect.height / H)` and center the glyph.
- Add `pt(x, y)` to map image coordinates into the supplied `rect`, and `len(v)` for radii.
- Reproduce `build(P)` call by call: `fillet` becomes
  `addArc(tangent1End:tangent2End:radius:)`; `arc(c, r, a, a + 180)` becomes
  `addRelativeArc(center:radius:startAngle:delta:)`; a circle becomes a 360-degree relative
  arc. Prefer `addRelativeArc` over `addArc(... clockwise:)`: screen-coordinate y direction
  makes a guessed clockwise flag a common source of arcs going the wrong way.
- Paste the final `params.json` values as commented constants so the source of every number
  remains clear.

### Step 4 - Verify the Shape (required)

```sh
scripts/render_shape.sh MyLogoShape.swift MyLogoShape render.png \
    --canvas 1254 1254 --frame 418 441 387 370          # canvas = source; frame = glyph bbox
python3 scripts/compare.py logo.png render.png            # IoU + overlay
scripts/render_shape.sh MyLogoShape.swift MyLogoShape outline.png --mode stroke --canvas 400 400 --frame 50 50 300 300
scripts/render_shape.sh MyLogoShape.swift MyLogoShape half.png --mode trim --trim 0.5 --canvas 400 400 --frame 50 50 300 300
```

SwiftUI IoU should match the Python model within 0.01. If it does not, an arc may be taking
the wrong side or a normal may have the wrong sign. Inspect `outline.png` for clean contours
without loops and `half.png` to confirm that the trace stops at the intended point.

### Step 5 - Integrate into the app

```swift
LogoDraw(MyLogoShape(), drawDuration: 1.2, fillStartPercent: 70, size: 150,
         outlineColor: .primary, fillColor: .primary, freezeAt: freeze) { splashDone() }
```

- Use `onComplete` to chain actions such as closing the splash screen or showing a wordmark.
- Expose `freezeAt` through a launch argument such as `-splash.freeze 0.45` to inspect and
  screenshot any frame in the simulator.
- Respect Reduce Motion: show the completed logo and invoke `onComplete` immediately.

## Deliverables

1. `MyLogoShape.swift`, with comments recording where the measurements came from;
2. `models/my_logo.py` and `params.json`, so the logo can be regenerated when the source changes;
3. `overlay.png` and the measured IoU as evidence of fidelity;
4. the integration point in the app.
