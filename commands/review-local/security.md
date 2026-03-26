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

**Dependencies**:
- Flag known-vulnerable dependency versions (check against advisories if version is visible in diff)
- Flag wildcard version constraints (`*`, `>=0`) in package manifests — supply chain risk
