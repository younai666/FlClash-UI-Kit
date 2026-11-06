# Native Canvas field

This package extracts FlClash's native JavaScript Canvas effect from `site/assets/field.js`, commit `be84736605527034689c95bf27828ff27d912c5e`. It retains the spring, palette, lane geometry, pointer wake, scroll tempo, viewport/pixel budget and visibility/reduced-motion hooks. It has no runtime dependencies.

```js
import { mountField } from './packages/web/index.js';
const field = mountField(canvas, {
  avoid: () => [panelRectRelativeToCanvas],
  still: () => matchMedia('(prefers-reduced-motion: reduce)').matches,
});
// After changing theme, obstacles or pause state:
field?.refresh();
// To wake resting capsules:
field?.surge();
// On component unmount:
field?.dispose();
```

Give the canvas a real CSS size. Rectangles use canvas-local coordinates. `stage` optionally supplies the region for the original glyph arrangement; it defaults to null. `still` defaults to false, so hosts must connect their reduced-motion preference. Import `tokens.css` for the original light/dark CSS variables, or provide the documented `--field-1` through `--field-6` and `--g1` through `--g3` variables yourself. These site tokens are distinct from the Flutter application's seed-generated theme.

For React or another lifecycle-based host, call `mountField` after mounting the canvas and return `field?.dispose()` from cleanup. Mount returns null when Canvas 2D is unavailable. Do not call a disposed handle; mount a new one.

The actual interactive example is [web-field.html](../../showcase/web-field.html). Serve the repository root over localhost HTTP and open `/showcase/web-field.html`. ES modules should not be tested by opening a file URL. Run `npm test` for the lifecycle regression test; actual browser evidence is separately recorded in [verification.md](../../docs/audit/verification.md).

`tools/extract_web.py` reproduces the original implementation plus explicit cleanup of RAF, observers and listeners. GPL-3.0 is retained in LICENSE; source and modifications are recorded in `docs/audit/web-extractions.json`. This package provides this native JavaScript effect; it does not expose Flutter components to JavaScript.
