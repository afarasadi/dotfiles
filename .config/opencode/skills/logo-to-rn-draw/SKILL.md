---
name: logo-to-rn-draw
description: Convert a logo image (PNG) into a clean React Native Skia path and a Reanimated component that traces its outline before revealing the fill for splash screens, loading states, and hero animations. Use when the user asks to draw, animate, vectorize, or trace a logo, or requests a React Native, Skia, or Reanimated logo animation.
---

# logo-to-rn-draw

## Principle

A traced logo only looks good when its `SkPath` is **clean**: use a small number of
primitives, avoid self-intersections, and order subpaths as a pen would draw them.
Automatic vectorization with potrace can be faithful but often produces too many nodes.
For geometric logos, reconstructing the shape with primitives and **measuring fidelity**
against the source image is more reliable than trusting visual inspection alone.

The renderer is `@shopify/react-native-skia` and the animation is driven by
`react-native-reanimated`. The job of this skill is to produce the static `SkPath`, the
coordinate mapping, and a reusable component that draws the outline before revealing the
fill. Keep the animation state on the UI thread; do not rebuild paths or trigger React
renders for every frame.

## Prerequisites

- A React Native app with `@shopify/react-native-skia` and `react-native-reanimated` v4
  installed and configured according to the app's native and Babel setup, including the
  Reanimated v4 worklets runtime used by `scheduleOnRN`.
- Python 3 with `numpy`, `pillow`, and `scipy`.
- For path B (organic logos): `brew install potrace`.
- A native Canvas snapshot or screenshot harness. `Canvas` snapshots through
  `useCanvasRef().current?.makeImageSnapshot()` are preferable for pixel comparisons.

The measurement, geometry, tuning, and comparison utilities are renderer-independent and
are available in the sibling `logo-to-swiftui-draw/scripts/` directory:
`measure.py`, `geometry.py`, `tune.py`, and `compare.py`. Reuse those files for this
workflow. Do not use its `render_shape.sh`, which is SwiftUI-specific. Run the utilities
from a temporary working directory and pass their paths explicitly.

## Workflow

### Step 0 - Classify the logo

Open the image and decide:

- **Geometric** (constant-width strokes, circles, rounded corners, and straight lines):
  use path A. Examples include pictograms, monograms, and flat symbols.
- **Organic** (lettering, freeform shapes, or variable widths): use path B.

When uncertain, start with path A and measure it. If a small set of primitives cannot reach
roughly 0.90 IoU, the logo is not geometric enough for that approach.

### Step 1 - Measure both paths

Set a variable to the absolute path of the sibling scripts directory, then run:

```sh
LOGO_SCRIPTS=/path/to/opencode/skills/logo-to-swiftui-draw/scripts
python3 "$LOGO_SCRIPTS/measure.py" logo.png --mask mask.png
```

The output contains the image size and connected components with bounding boxes. Inspect
`mask.png`: the threshold must isolate only the glyph (use `--threshold` or `--dark`). If
the image contains a wordmark or a bright background, record a `y` value below which pixels
should be ignored with `--ignore-below`.

Take row and column runs for each component:

```sh
python3 "$LOGO_SCRIPTS/measure.py" logo.png --rows 520 720 6
python3 "$LOGO_SCRIPTS/measure.py" logo.png --cols 400 700 12
```

Derive measurements rather than guessing: stroke width (horizontal width multiplied by the
sine of the angle), line angles (the `dx/dy` change between rows), centers and radii of round
ends (extreme point plus half the stroke width), and the transition from a line to a curve.

### Step 2A - Model geometric logos with primitives

Copy `logo-to-swiftui-draw/scripts/models/runner.py` as a starting point. Keep the model in
the working directory, not in the app bundle, and keep `geometry.py` beside it so the model's
relative import continues to work. A model contains:

- `PARAMS`: a dictionary of measured widths, centers, angles, and radii;
- `build(P)`: a list of polygons, **one per subpath**, built from `fillet`, `arc`, and lines;
- `STEPS` and `VEC_STEPS`: the search step for each parameter.

Rules that prevent rework:

- Build **explicit contours**, not a stroked centerline. Explicit contours control the start
  point, make filling predictable, and avoid self-intersections when a curve radius is less
  than half the stroke width.
- The outer and inner corners of a stroke are not always concentric in hand-drawn or
  AI-generated logos. Measure both radii separately.
- Subpath order is animation order. Start with the largest piece and finish with the detail.
- Keep all model coordinates in source-image pixels. Do not normalize or round values before
  the fit is complete.

Measure and tune:

```sh
mkdir -p models
cp "$LOGO_SCRIPTS/geometry.py" geometry.py
cp "$LOGO_SCRIPTS/models/runner.py" models/my_logo.py
python3 "$LOGO_SCRIPTS/tune.py" logo.png models/my_logo.py                 # IoU + overlay.png
python3 "$LOGO_SCRIPTS/tune.py" logo.png models/my_logo.py --tune          # coordinate descent -> params.json
```

Read `overlay.png`: red is where the model extends beyond the source and green is where the
source is missing from the model. Adjust the construction, not only the numbers, until the
remaining error is mostly antialiasing and the source image's edge noise.

### Step 2B - Vectorize organic logos

```sh
potrace mask.pbm -s -o logo.svg --turdsize 20 --alphamax 1 --opttolerance 0.4
```

Generate the `.pbm` from `mask.png` with Pillow. If the resulting path has too many nodes,
simplify it in Figma or Illustrator and export it again. Parse the SVG `d` data with
`Skia.Path.MakeFromSVGString(d)` when possible. If the SVG has transforms, resolve them
before fitting the path, or apply one fixed transform when constructing the Canvas scene.
For a parser fallback, reproduce `move`, `line`, `quadratic`, `cubic`, `arc`, and `close`
commands with `SkPath` methods. Preserve subpath order and winding direction; the component
can animate either path source, but trace quality depends on sensible drawing direction and
a manageable number of nodes.

### Step 3 - Port to React Native and Skia

Create `MyLogoPath.ts` (or `MyLogoDraw.tsx`) and follow these rules:

- Set `designSize` to the source glyph bounding box. For a Canvas of `width` x `height`,
  calculate `scale = min(width / W, height / H)` and center the glyph while preserving its
  aspect ratio.
- Map source coordinates with a single function such as
  `x = offsetX + (sourceX - bbox.minX) * scale` and
  `y = offsetY + (sourceY - bbox.minY) * scale`. Scale radii by the same `scale`.
- Build the path once per size or parameter change with `Skia.Path.Make()`. Use
  `moveTo`, `lineTo`, `quadTo`, `cubicTo`, and `close`, and close every contour explicitly.
  Wrap the builder in `useMemo` in a component; never allocate a `SkPath` inside an animated
  worklet or once per frame.
- Reproduce `build(P)` call by call. A `fillet` becomes a tangent arc (`arcTo` or an
  equivalent cubic arc), `arc(c, r, a, a + 180)` becomes `addArc(Skia.XYWHRect(...), a,
  sweep)`, and a circle becomes `addCircle`. Use a signed sweep that matches the measured
  contour direction. Skia has no SwiftUI-style `clockwise` flag to guess around; verify the
  direction with a snapshot instead of blindly negating angles.
- Preserve subpath order and choose the fill rule deliberately when the logo has holes.
  A wrong winding or fill rule can look correct as a stroke but produce incorrect fill pixels.
- Store the final `params.json` values as typed constants with a comment recording their
  source measurements.

A minimal static path builder has this shape:

```tsx
import { Skia, type SkPath } from '@shopify/react-native-skia';

type Point = { x: number; y: number };

export function makeMyLogoPath(mapPoint: (x: number, y: number) => Point): SkPath {
  const path = Skia.Path.Make();
  const start = mapPoint(0, 0); // replace with the measured source coordinates
  const next = mapPoint(100, 100); // replace with the next measured point
  path.moveTo(start.x, start.y);
  path.lineTo(next.x, next.y);
  // Add measured arcs and curves in drawing order.
  path.close();
  return path;
}
```

The example is a structure, not a reason to approximate a curved logo with arbitrary line
segments. Keep actual arc and cubic geometry in the production path.

### Step 4 - Animate and verify the Skia path (required)

Use one Reanimated shared value for the normalized timeline. Pass shared values directly to
Skia props; do not use React state or `setState` per frame:

```tsx
import { useEffect } from 'react';
import { Canvas, Path, type SkPath } from '@shopify/react-native-skia';
import { scheduleOnRN } from 'react-native-worklets';
import {
  cancelAnimation,
  Extrapolation,
  interpolate,
  useDerivedValue,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';

type LogoDrawProps = {
  path: SkPath;
  width: number;
  height: number;
  outlineColor: string;
  fillColor: string;
  strokeWidth: number;
  onComplete?: () => void;
};

function LogoDraw({
  path,
  width,
  height,
  outlineColor,
  fillColor,
  strokeWidth,
  onComplete,
}: LogoDrawProps) {
  const progress = useSharedValue(0);
  const outlineEndAt = 0.7; // fillStartPercent / 100
  const outlineEnd = useDerivedValue(() =>
    interpolate(progress.get(), [0, outlineEndAt], [0, 1], Extrapolation.CLAMP),
  );
  const fillOpacity = useDerivedValue(() =>
    interpolate(progress.get(), [outlineEndAt, 1], [0, 1], Extrapolation.CLAMP),
  );

  useEffect(() => {
    progress.set(
      withTiming(1, { duration: 1200 }, (finished) => {
        if (finished && onComplete) {
          scheduleOnRN(onComplete)();
        }
      }),
    );
    return () => cancelAnimation(progress);
  }, [onComplete, progress]);

  return (
    <Canvas style={{ width, height }}>
      <Path
        path={path}
        color={outlineColor}
        style="stroke"
        strokeWidth={strokeWidth}
        strokeCap="round"
        strokeJoin="round"
        start={0}
        end={outlineEnd}
      />
      <Path path={path} color={fillColor} style="fill" opacity={fillOpacity} />
    </Canvas>
  );
}
```

The animation code must be completed as a component, not pasted literally into render
scope: start `withTiming` from an effect or an explicit command, handle cancellation, and
keep the `SkPath` and static dimensions outside the frame loop. Replace the `scheduleOnRN`
call with the app's existing Reanimated bridge helper if its setup uses a different import. In
Reanimated v4, prefer `progress.get()` and `progress.set()` in application code. Notify
`onComplete` only from the finished animation callback. Never bridge on every frame.

The normalized `start` and `end` values trim the combined path in its subpath order. If the
logo needs independent timing for separate pieces, keep one static path per piece and derive
each piece's range from the same timeline rather than rebuilding paths during animation.

Required component behavior:

- `drawDuration` controls the full timeline.
- `fillStartPercent` controls when the outline is complete and fill reveal begins; clamp it
  to a useful range such as 0 through 100, and branch or use an epsilon at the endpoints so
  the interpolation input range never has equal values.
- `freezeAt` accepts a normalized value from 0 through 1 for deterministic review and
  screenshots. A frozen frame must not start a competing timing animation.
- `onComplete` fires once after a non-cancelled animation reaches 1.
- Respect Reduce Motion with Reanimated's reduced-motion support or the app's established
  accessibility hook: show the complete logo and invoke `onComplete` immediately.

For the pixel comparison, render the native Canvas at the source image's exact pixel
dimensions with a known background. Capture it with a Canvas ref (`makeImageSnapshot`) or a
native screenshot harness, then run:

```sh
python3 "$LOGO_SCRIPTS/compare.py" logo.png rn-render.png            # IoU + overlay.png
```

The source and render must have identical dimensions. The RN render should match the Python
model within 0.01 IoU after accounting for antialiasing. If it does not, inspect
`overlay.png`: a large mismatch usually means a coordinate transform, fill rule, arc sweep,
or path winding is wrong. Also capture a complete `outline.png` and a `half.png` with
`freezeAt={0.5}`. The first must have clean contours without loops; the second must stop at
the expected subpath and must not reveal the fill early.

### Step 5 - Integrate into the app

```tsx
<LogoDraw
  path={myLogoPath}
  designSize={designSize}
  drawDuration={1200}
  fillStartPercent={70}
  size={150}
  outlineColor={colors.primary}
  fillColor={colors.primary}
  freezeAt={__DEV__ ? freeze : undefined}
  onComplete={splashDone}
/>
```

- Use `onComplete` to chain actions such as closing the splash screen or showing a wordmark.
- Expose `freezeAt` through a dev-only control, deep link, Storybook prop, or test fixture so
  any frame can be reviewed without changing production behavior.
- Keep `Canvas` sizing and the path's coordinate transform deterministic across device sizes.
- Do not replace the Skia path with a browser SVG or a `react-native-svg` stroke when the
  requested output is Skia.

## Performance requirements

- Keep the timeline in `useSharedValue` and derive trim, opacity, and other animated values
  on the UI thread.
- Pass Reanimated shared values directly to Skia-compatible props; avoid React renders per
  frame and avoid `runOnJS` or `scheduleOnRN` in hot paths.
- Memoize the static `SkPath`, `RuntimeEffect`, paints, and images. Do not allocate arrays,
  paths, or large objects inside `useDerivedValue` or animated styles.
- Prefer a shallow Canvas scene and transforms over per-frame layout changes.

## Deliverables

1. `MyLogoPath.ts` and `LogoDraw.tsx`, with comments recording the source measurements and
   coordinate system;
2. `models/my_logo.py` and `params.json`, so the logo can be regenerated when the source changes;
3. `rn-render.png`, `outline.png`, `half.png`, `overlay.png`, and the measured IoU as evidence
   of fidelity;
4. the integration point in the React Native app.
