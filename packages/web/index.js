import './field.js';

/** Mount the original FlClash Canvas effect; call dispose on unmount. */
export const mountField = (canvas, options) => globalThis.FlClashField.mount(canvas, options);
