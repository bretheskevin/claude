## Rust Best Practices

**Ownership & borrowing**:
- Prefer borrowing (`&T`, `&mut T`) over cloning unless ownership transfer is needed
- Flag unnecessary `.clone()` — especially on types that implement `Copy` or where a borrow suffices
- Flag `Rc`/`Arc` used where ownership can be restructured to avoid shared pointers

**Error handling**:
- Use `?` operator — flag manual `match` on `Result`/`Option` that could be `?` or combinators
- Prefer `thiserror` for library errors, `anyhow` for application errors — flag raw `String` errors
- Flag `.unwrap()` / `.expect()` outside of tests — use `?` or proper error propagation
- Flag `panic!` in non-test code

**Idiomatic patterns**:
- Prefer `if let` / `let else` over `match` with a single arm + wildcard
- Use `Iterator` combinators (`map`, `filter`, `collect`) over manual loops when clearer
- Flag `&String` parameters — use `&str` instead
- Flag `&Vec<T>` parameters — use `&[T]` instead
- Flag `Box<dyn Error>` in public APIs — use typed errors
- Prefer `impl Trait` in argument position over generic bounds when there's a single caller

**Async**:
- Flag `.await` inside loops that could be `join_all` / `FuturesUnordered`
- Flag `tokio::spawn` without `JoinHandle` being tracked (fire-and-forget tasks)
- Flag blocking calls (std file I/O, `thread::sleep`) inside async functions

**Safety & performance**:
- Flag `unsafe` blocks without a `// SAFETY:` comment explaining the invariant
- Flag `to_string()` / `format!()` in hot paths where `&str` or `Cow<str>` would suffice
- Prefer `Vec::with_capacity` when the size is known ahead of time

**Desktop security** *(Rust-specific — supplement to `security.md`, do not re-flag items already covered universally)*:
- Flag `std::process::Command` with user-provided arguments without sanitization — command injection
- Flag `std::process::Command` using shell invocation (`sh -c`, `cmd /c`) with interpolated input — shell injection
- Flag file operations with user-provided paths without canonicalization (`std::fs::canonicalize`) — path traversal via `../`
- Flag TOCTOU patterns: checking file existence/permissions then operating separately (race condition) — use atomic operations or lock files
- Flag following symlinks without verification in security-sensitive paths
- Flag secrets stored in `String` — heap content persists after drop; use `secrecy::Secret<String>` or `zeroize`
- Flag `#[derive(Debug)]` on structs containing secrets, passwords, or tokens — will print them in logs/panics
- Flag logging (`tracing`, `log`) of sensitive fields (passwords, tokens, API keys)
- Flag `reqwest` / HTTP client with `.danger_accept_invalid_certs(true)` — disables TLS verification
- Flag hardcoded credentials in HTTP client configuration or source code
- Flag user-provided URLs passed to HTTP clients without validation — SSRF
- Flag `rand::thread_rng()` for tokens, nonces, or keys — use `OsRng` or `rand::rngs::StdRng` seeded from `OsRng`
- Flag `transmute` without strong safety justification — type confusion, UB
- Flag `unsafe impl Send` / `unsafe impl Sync` without rigorous safety argument
- Flag `serde::Deserialize` on untrusted network input without size/depth limits — DoS via deeply nested or oversized payloads
- Flag `Mutex::lock().unwrap()` without recovery strategy — panics on poisoned mutex crash the app

**Tauri-specific** (if `tauri` in `Cargo.toml`):
- Flag overly broad permissions in `tauri.conf.json` / capabilities — principle of least privilege
- Flag `#[tauri::command]` handlers that don't validate or sanitize input from the frontend
- Flag `shell:open` scope allowing arbitrary URLs — restrict to known schemes/domains
- Flag missing or overly permissive CSP in Tauri config
- Flag `dangerousRemoteDomainIpcAccess` enabled — allows untrusted origins to call Tauri commands
- Flag `fs` scope allowing access outside app data directory
