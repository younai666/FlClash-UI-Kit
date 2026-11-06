# FlClash native editor

Use this complete directory together with its sibling `../flutter`. Native builds require Flutter, Rust 1.99.0 and the target platform toolchain. It includes the complete CodeForge Dart renderer, editor-only Rust document backend, locked dependencies, generated FRB 2.13.0 bindings and build hook.

Call `WidgetsFlutterBinding.ensureInitialized()` and `await initializeEditor()` before creating CodeForge controllers. Construct `NativeCodeEditor` with CodeForgeController, FindController, UndoRedoController and explicit EditorLanguage/readOnly inputs. `fontSize`, `lineWrap`, `completionSource` and `topInset` are optional. Null topInset preserves upstream floating-bar clearance; zero suits an inline area below a toolbar. Dispose the controllers in the host.

The runnable example is `showcase/lib/editor_native.dart` in the repository. Native controller and UI tests are in test; original CodeForge behavior suites are under test/upstream. File workflows, proxy services and Clash-specific schema are not implicitly started. The declared upstream Rust targets cover Android, Windows, macOS and Linux; Web is unsupported, and iOS targets are not yet declared or verified.

See NOTICE.md, LICENSE and assets/licenses/rust-dependencies.txt for retained permissions and source attribution. Keep vendor, assets and the sibling base package when copying this package. Regenerate bindings from vendor/rust_api with flutter_rust_bridge_codegen 2.13.0; do not point it at the upstream application's service crate.
