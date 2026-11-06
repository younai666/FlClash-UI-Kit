export interface FieldRect { left: number; top: number; right: number; bottom: number }
export interface FieldOptions {
  /** Bounds relative to the canvas, such as text/buttons to keep clear. */
  avoid?: () => FieldRect[];
  /** Optional region where the original logo arrangement assembles. */
  stage?: () => FieldRect | null;
  /** Host-owned reduced-motion or pause state; call refresh after changing. */
  still?: () => boolean;
}
export interface FieldHandle {
  refresh(): void;
  surge(): void;
  dispose(): void;
}
export function mountField(canvas: HTMLCanvasElement, options?: FieldOptions): FieldHandle | null;
