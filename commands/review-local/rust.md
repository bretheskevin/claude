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
