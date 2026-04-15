## Security — Universal Rules

Always flag as **issue** (never suggestion). Explain the attack vector, not just "insecure".

**API Security**:
- Flag endpoints without authentication check — unauthorized access
- Flag resource access by ID without ownership/tenant scoping — IDOR
- Flag missing rate limiting on sensitive endpoints (login, password reset, OTP, account creation) — brute force / credential stuffing
- Flag API responses returning more fields than the consumer needs — data leakage via over-fetching
- Flag error responses that expose internal details (stack traces, SQL errors, internal paths) to end users — information disclosure

**Injection**:
- Flag user data concatenated/interpolated into SQL, shell commands, LDAP queries, or templates — use parameterized queries, allowlists, or framework-provided sanitization
- Flag `eval()` / `new Function()` / `Marshal.load` / `YAML.unsafe_load` / `pickle.loads` with untrusted data — code execution
- Flag `innerHTML` / `outerHTML` / `dangerouslySetInnerHTML` with dynamic user-provided content — XSS

**Secrets & Data Exposure**:
- Flag hardcoded secrets (API keys, passwords, tokens, connection strings) in source code — use environment variables or secret managers
- Flag sensitive data in logs (PII, tokens, passwords, card numbers, SSNs) — configure log filtering
- Flag secrets in frontend bundles (`environment.ts`, `.env` files exposed to client build) — visible in browser devtools
- Flag source maps shipped to production — exposes original source code
- Flag `.env` files, credentials files, or private keys added to version control

**Cryptography**:
- Flag `Math.random()` / `rand::thread_rng()` / non-CSPRNG used for security tokens, nonces, or keys — use crypto-secure alternatives (`crypto.randomUUID()`, `OsRng`, `SecureRandom`)
- Flag MD5 / SHA1 used for password hashing or security integrity — use bcrypt, argon2, scrypt, or SHA-256+
- Flag secret/token comparison with `==` — timing attack; use constant-time compare (`secure_compare`, `hmac.compare_digest`, `ring::constant_time`)
- Flag custom cryptographic implementations — use established libraries (openssl, ring, libsodium)
- Flag weak/deprecated TLS configuration or disabled certificate verification

**File Uploads & File System**:
- Flag file uploads without validation of type, size, and content — unrestricted file upload
- Flag user-controlled file paths without canonicalization — path traversal via `../`
- Flag files stored with user-provided filenames without sanitization — directory traversal, overwrite
- Flag serving uploaded files without Content-Disposition/Content-Type hardening — stored XSS

**Redirects & Navigation**:
- Flag redirect destination from user input without allowlist — open redirect (phishing vector)
- Flag `postMessage` listener without `event.origin` verification — cross-origin message spoofing
- Flag `window.open` / `shell.open` / `href` assignment with user-controlled URLs without scheme validation

**Session & Transport**:
- Flag tokens stored in `localStorage` — XSS-accessible; prefer httpOnly cookies
- Flag session cookies without `secure`, `httponly`, `samesite` flags
- Flag CSRF protection disabled on state-changing endpoints without justification
- Flag CORS with `Access-Control-Allow-Origin: *` combined with credentials — credential theft
- Flag sensitive data transmitted over HTTP (non-TLS) or with TLS verification disabled

**SSRF (Server-Side Request Forgery)**:
- Flag backend HTTP requests where the URL, hostname, or IP comes from user input — attacker can scan internal networks, hit metadata endpoints (169.254.169.254), or access internal services
- Flag URL allowlists based on regex or string matching without also resolving DNS and validating the IP — DNS rebinding bypasses hostname checks

**Regex Denial of Service (ReDoS)**:
- Flag regex with nested quantifiers (`(a+)+`, `(a|a)*`, `(.*a){n}`) applied to user-provided input — a single crafted string can freeze the process
- Flag regex built dynamically from user input without escaping — use the language's regex escape utility (`Regexp.escape`, `re.escape`, `escapeRegExp`)

**Race Conditions / TOCTOU**:
- Flag check-then-act patterns on shared mutable resources without atomicity (e.g., "if balance >= amount, then deduct" without transaction/lock) — double-spend, privilege escalation
- Flag file existence checks followed by file operations without locking — time-of-check to time-of-use gap
- Flag non-atomic read-modify-write sequences on shared state (counters, flags, balances) without optimistic locking, database-level constraints, or mutex

**HTTP Security Headers**:
- Flag new server/middleware configuration missing security headers: `Content-Security-Policy`, `X-Frame-Options`, `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`
- Flag `X-Frame-Options` set to `ALLOWALL` or missing on endpoints serving HTML — clickjacking
- Flag `Strict-Transport-Security` missing or with short `max-age` on production HTTPS endpoints

**Host Header Injection**:
- Flag `request.host`, `Host` header, or `X-Forwarded-Host` used to construct URLs (password reset links, OAuth callbacks, redirect targets) without allowlist validation — attacker can poison links to redirect users to malicious domains

**Unbounded Deserialization**:
- Flag parsing untrusted input (network requests, file uploads, message queues) without size or depth limits — DoS via oversized or deeply nested payloads
- Applies to any format: JSON, XML, MessagePack, Protobuf, YAML — if the parser accepts arbitrary input, enforce max size at the transport layer and max depth/nesting at the parser layer

**Dependencies**:
- Flag known-vulnerable dependency versions (check against advisories if version is visible in diff)
- Flag wildcard version constraints (`*`, `>=0`) in package manifests — supply chain risk
