# 维护与更新

上游锁定版本见 source/upstream-lock.json。`source/upstream` 是只读参考快照；库内 vendor 是可构建的交付代码，二者有不同用途。

1. 在更新分支 fetch 上游，先比较两个新 Commit 和 FlClash 的嵌套 prism_ui pin，不直接切到不明 HEAD。
2. 重新枚举所有跟踪文件/子模块、全文调查 import/part/资源/动效/平台差异；阅读发生变化的函数和调用者。`python tools/audit.py --write` 生成机器清点，不能代替语义审查。
3. 更新对应提取器（extract、extract_editor、extract_platform、extract_web）的版本和有依据的变换，再执行它。`--check` 必须与交付文件和完整来源账册一致；Web clipBehavior 补丁在新 SDK/上游已经解决时应删除，而不是无限叠加兼容层。
4. 更新源码锁、提取矩阵、组件目录和真实 Showcase。参考-only、部分提取、完整提取与运行验收分别记录；未支持的页面不能靠文件计数变成“完成”。
5. 分别运行 flutter、editor、platform 包与 Showcase 的静态分析和受影响测试。原生 editor 测试必须加载真实 Rust 后端；在其 vendor/rust_api/rust 运行 `cargo test --locked`。改变 prism_ui 时，在组件包目录运行 `flutter test ../../source/upstream/prism_ui/test`，用交付包实际依赖解析运行保留的上游套件。改变 Web 动效时运行下方 Node 生命周期测试及真实浏览器验证。
6. 为实际目标构建 Showcase。Web 的条件导入不验证原生编辑器；Windows 编译不证明 macOS/Linux/iOS 兼容；APK 编译不等于真机运行。记录 SDK、工具链、设备与交互证据。
7. 重新生成四个实际消费者的 Dart 许可和 Cargo.lock 全图许可，核对新增二进制资产的来源授权，再生成运行时 notice 资产。记录验证结果，检查 README 与 Skill 引用、仓库外完整包独立消费方式和安装提示词。

```bash
python tools/audit.py --check
python tools/extract.py --check
python tools/extract_editor.py --check
python tools/extract_platform.py --check
python tools/extract_web.py --check
python tools/render_audit.py
python tools/catalog.py
python tools/dependency_licenses.py
# 先创建 .local，并用实际工具链生成完整 Cargo 元数据；不可加 --no-deps。
cargo +1.99.0 metadata --manifest-path packages/editor/vendor/rust_api/rust/Cargo.toml --locked --format-version 1 > .local/cargo-metadata.json
python tools/rust_licenses.py
python tools/bundled_notices.py
node --test packages/web/test/field.test.js
python tools/check_repository.py
```

这些维护命令不安装全局 Skill，不发布或推送代码；Cargo/Flutter 首次执行会填充本机工具链与依赖缓存。更新依赖时检查锁文件实际差异；不要让无关依赖升级混入 UI 提取改动。生成的清点、目录和测试数量不能代替语义审查或视觉对照。
