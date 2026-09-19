---
name: ui-slicing
description: Use for `/uislicing`, UI reference slicing, atomic-design mapping, component parity, annotated visual references, crop baselines, and screenshot verification across platforms.
compatibility: macOS projects with native image tools and optional Argent device access.
---

# UI Slicing

Use this skill to turn a visual reference into a reusable, semantic component
contract and a repeatable visual verification set. The reference image is the
visual source of truth; ASCII is allowed only as a supplemental semantic note.

## Trigger

Run this workflow when the user invokes `/uislicing` or asks to:

- slice, crop, annotate, or map a UI reference image;
- identify which reusable atoms, molecules, organisms, and screens make up a design;
- verify that an implementation matches a sliced reference component;
- create screenshot baselines or visual regression checks from a design image.

If the user gives an image path, use that exact file. If no path is supplied,
ask for one instead of inventing a reference.

## Design Principles

### Semantic agnosticism

Component roles must describe reusable behavior and visual responsibility, not
the screen where the component happened to appear.

Good roles:

- `circular-badge`
- `icon-button`
- `primary-action-button`
- `text-with-trailing-icon`
- `metric-cell`
- `streak-day-cell`
- `header`
- `streak-card`
- `hero-card`
- `plan-card`
- `progress-section`
- `navigation-item`

Avoid roles such as `home-finished-badge`, `profile-specific-card`, or
`today-plan-only-row` unless the product behavior genuinely makes them
non-reusable. State belongs in data or a variant, not in a new component type.

### Atomic design levels

- **Atom**: one reusable visual or interaction primitive, such as an icon, text block, badge, button, chevron, metric cell, or navigation item.
- **Molecule**: a small composition with one responsibility, such as a header, vocabulary row, streak card, or latest-session row.
- **Organism**: a reusable section composed of molecules and atoms, such as a hero card, plan card, or progress section.
- **Screen**: a stateful composition of organisms and shell primitives.

Do not make separate components merely because the reference has `initial`,
`finished`, or `continue` screens. Use one reusable component with a typed
state/variant fixture when the structure is the same.

## Required Artifacts

For a source image named `home_screen.png`, create one artifact folder beside
it, named after the source basename:

```text
home_screen.png
home_screen/
  annotated.png                  # readable macro overview only
  annotated.svg                  # editable source for the macro overview
  slices/                        # one clean crop per reusable region
  slices.json                    # screen and crop manifest
  atom_map.json                  # crop-relative atom boxes and semantic roles
  design_contract.json           # machine-readable Figma-style design contract
  design_contract.md              # human-readable contract for review
```

Keep all generated artifacts inside that folder. Use a different folder name
when the input image has a different basename.

The optional `scripts/measure.py` helper can inspect dimensions, connected
components, masks, and row/column runs when image geometry needs investigation:

```sh
python3 scripts/measure.py home_screen.png --mask home_screen/mask.png
```

Use native image tools instead when Python dependencies are unavailable. This
helper is not required by the workflow.

### Macro overview

The macro image may contain:

- screen boundaries;
- state boundaries using distinct colors;
- one label per major region;
- no dense atom labels.

Suggested state colors are blue for initial, amber for finished, and green for
continue. Keep labels inside or immediately beside their region. The overview
must remain readable at normal image size.

### Crops

Create clean crops with no annotation painted over the design. Each crop must
represent one visual contract, for example:

```text
initial_hero.png
finished_streak.png
continue_plan.png
```

Use one crop for a full molecule/organism and map its child atoms in the atom
manifest. Do not put every atom from the whole screen on one canvas; overlapping
labels make the reference harder to inspect than the original image.

### Slice manifest

The slice manifest must record:

- source image and coordinate dimensions;
- state and screen role;
- crop filename;
- absolute source box `[x, y, width, height]`;
- semantic component role;
- implementation targets, when known;
- Storybook story or preview target, when one exists.

### Atom map

The atom map must record child boxes relative to their crop, not only absolute
screen coordinates. Each atom entry should include:

```json
{
  "id": "action",
  "role": "primary-action-button",
  "box": [20, 156, 177, 52],
  "storybook": "Atoms/Primary action button"
}
```

When a platform has no separate atom story, map the atom to the smallest
available reusable implementation and say that the story is missing instead of
pretending the organism story proves atom parity.

### Design contract

Slicing is incomplete until every clean crop has a design contract. The clean
crop is the visual oracle; the contract is the Figma-style inspect specification
that explains how to reproduce it. Do not begin implementation from the crop
alone and do not treat an atom role or bounding box as a complete specification.

Write the contract twice:

- `design_contract.json` is the machine-readable source for tooling and code generation.
- `design_contract.md` is the human-readable source for review and design sign-off.

The contract must describe each screen, slice, molecule, organism, and nested
primitive. Reuse a component contract through explicit variant data rather than
copying a screen-specific contract.

Every contract node must support these Figma-like property groups:

- `identity`: stable id, semantic role, atomic-design level, parent, and Storybook/preview target.
- `frame`: reference-pixel box, sizing mode (`fixed`, `fill`, or `hug`), min/max dimensions, and crop ownership.
- `layout`: axis, alignment, per-edge padding/insets, child gap, row/column gaps, ordering, anchors, constraints, and overflow/clipping.
- `surface`: fill token or measured color, opacity, border width/color/opacity, corner radii per corner, elevation/shadow, and blend behavior.
- `typography`: exact shared typography token, color token, text content, alignment, line limit, wrapping, truncation, baseline behavior, and text transform.
- `asset`: asset or drawing id, content mode, visual bounds, slot bounds, scale, tint/fill, stroke width, line cap, line join, and layer order.
- `interaction`: hit target, accessibility role/label, enabled/selected state, and action semantics.
- `variants`: state-specific content or geometry overrides with no duplicated component role.
- `evidence`: source image, crop id, atom id, measurement method, confidence, and whether the value is `measured`, `token`, `derived`, or `inferred`.

Geometry is always stored in the reference image's declared coordinate space,
normally source-image pixels. Never write reference pixels as Android `dp` or
iOS points in the contract. Renderers derive platform units from the target
content width. If a visual atom box differs from its layout slot, record both
`box` and `layoutBox`; do not force visual bounds into a flex layout model.

Text must reference a named typography token such as
`Typography.titleLarge`, `Typography.bodySmall`, or `Typography.labelMedium`.
The contract may include the resolved token source path for traceability, but it
must not replace the token with an unexplained raw font size. Colors follow the
same rule through named `ColorScheme` tokens. Reference-only colors must be
given a stable token name and measured value.

For every icon or illustration, specify the primitive drawing contract rather
than only saying "icon": shape/path or asset id, bounds, optical alignment,
size, fill, stroke, cap, join, and clipping. Platform glyphs are not equivalent
unless the contract explicitly names the glyph and its visual constraints.

Atoms that sit outside a crop, including negative crop-relative coordinates,
must be marked as `context` atoms. They remain part of the parent composition
contract but are not part of the cropped visual diff.

A contract is not approved when it contains an unlabelled guess. Values that
cannot be measured from the reference or resolved from a project token must be
marked `inferred` and listed for review before implementation.

Example contract shape:

```yaml
component: latest-session-card
level: molecule
frame:
  box: [0, 0, 379, 84]
  units: reference-px
layout:
  direction: horizontal
  width: fill
  height: fixed
  padding: { top: 15, end: 13, bottom: 17, start: 10 }
  gap: 5
surface:
  fill: ColorScheme.surface
  border: { width: 1, color: ColorScheme.outlineVariant, opacity: 0.52 }
  cornerRadius: 17
children:
  - id: title
    role: text
    box: [77, 15, 175, 27]
    typography: Typography.titleLarge
    color: ColorScheme.onSurface
    content: copied-verbatim-from-reference
evidence:
  source: home_screen.png
  crop: slices/continue_latest.png
  atom: progressLatest.sessionTitle
  valueKinds: [measured, token]
```

The Markdown contract should read like a Figma inspect panel. Include the same
values as JSON, plus a primitive tree and a short note for every inferred or
platform-sensitive value.

## Implementation Workflow

1. Read the reference image and inspect its pixel dimensions.
2. Identify screen states and major regions before naming implementation files.
3. Build the macro annotated overview.
4. Create clean crops for each reusable molecule and organism.
5. Add crop-relative atom boxes and semantic roles to the atom map.
6. Define the Figma-style design contract for every crop and nested primitive.
7. Inspect existing source and Storybook catalogs only after the reference
   contract is explicit.
8. Reuse existing components where their semantics match; otherwise extract a
   reusable component instead of adding a screen-specific duplicate.
9. Keep state-specific differences in fixtures, data, or explicit variants.
10. Review the contract and resolve every unlabelled inference before coding.
11. Implement the smallest correct visual change from the approved contract.
12. Run the impacted platform's required development build after code changes.

Never edit generated FFI bindings or generated preview output manually.

## Verification Workflow

### Reference-to-component validation

For every crop:

1. Resolve its Storybook/preview target from the manifest.
2. Render the component at the crop's intended dimensions and fixture state.
3. Compare the implementation against the clean crop.
4. Check atom boxes inside the crop for typography, spacing, color, icon shape,
   clipping, alignment, and interaction affordance.
5. Record a pass/fail result against the crop id, not only against the full
   screen.

Visual similarity does not prove semantics. Also verify labels, roles,
clickability, navigation, and state with the platform accessibility tree or
component inspector.

### Argent runtime verification

When Argent is available:

- use `list-devices` and the platform setup skill first;
- use `describe` or the React Native component tree to locate controls;
- capture stable full-resolution screenshots with `screenshot`;
- use `screenshot-diff` only when the reference and current image have the same
  dimensions and matching crop boundaries;
- use structural inspection for accessibility and navigation assertions;
- never infer a pass from an approximate coordinate or a screenshot alone;
- verify each state separately, including loading and empty states.

For native mobile apps, runtime screenshots are the final acceptance evidence.
Clean crops are the component-level visual oracle; the full screen is the
composition oracle.

### Android Compose screenshot tests

If the project is Android Compose and the official Compose screenshot-testing
plugin is configured or can be added without conflicting with project rules,
add deterministic screenshot tests for reusable atoms, molecules, and
organisms using the same fixtures and dimensions as the crop manifest.

These tests must not replace Argent because they do not prove:

- iOS parity;
- installed-app navigation;
- native shell behavior;
- accessibility tree correctness;
- runtime integration between components.

Use Compose screenshot tests for fast Android rendering regression checks, then
use Argent for the cross-platform runtime acceptance path.

## Verification Matrix

Maintain a matrix in the final report or a project-local markdown file:

| Crop | Semantic role | Level | Story/preview | Runtime state | Visual | Structural |
|---|---|---|---|---|---|---|
| `initial_hero` | hero-card | organism | `Organisms/Hero - Initial` | initial | pass/fail | pass/fail |

Do not mark a parent crop as passing when a mapped child atom is visibly wrong.
Report the smallest failing role and its source location.

## Failure Classification

- **P0**: crash, inaccessible screen, missing primary action, or incorrect state/navigation.
- **P1**: wrong component structure, missing atom, severe clipping, or unusable interaction.
- **P2**: visible spacing, typography, icon, color, or alignment mismatch.
- **P3**: minor anti-aliasing or platform-rendering variance after structure and semantics match.

When a mismatch is found, include:

- crop id and atom id;
- expected reference behavior;
- observed implementation behavior;
- platform and device;
- source file and line;
- screenshot or diff evidence;
- whether the issue is shared, platform-specific, or fixture-specific.

## Completion Checklist

- [ ] Macro overview is readable and does not contain dense overlapping labels.
- [ ] Every reusable region has a clean crop.
- [ ] Every crop has semantic level and role metadata.
- [ ] Atom boxes are crop-relative and map to reusable roles.
- [ ] Every crop has a machine-readable and human-readable design contract.
- [ ] Contracts specify padding, gaps, sizing, alignment, surface, typography,
      colors, artwork primitives, clipping, interaction, and evidence.
- [ ] Every geometry value declares its coordinate units and evidence kind.
- [ ] Every typography and color value references a project token or a named
      measured reference token.
- [ ] No unlabelled inferred value remains before implementation begins.
- [ ] State variants use data/fixtures rather than screen-specific duplicates.
- [ ] Storybook/preview targets exist or missing coverage is explicitly reported.
- [ ] Argent runtime verification covers every requested state.
- [ ] Android Compose screenshot tests are added only where they provide useful fast regression coverage.
- [ ] Impacted platform builds and checks pass.
- [ ] Final report distinguishes visual, structural, and runtime evidence.
