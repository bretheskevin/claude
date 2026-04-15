## Rails Best Practices

**Thin controllers (ZERO logic in actions)**:
- Controller actions must contain ZERO business logic — no querying, no iteration, no destruction, no counting, no conditionals beyond simple guard clauses. Actions should ONLY: extract params, authorize, call a single service/model method, and render/redirect. Any action doing more than this is an **issue**, not a suggestion.
- Flag any direct model manipulation in actions (`.where`, `.find_by`, `.destroy`, `.update`, `.each`, `.map`, `.size`, `.count`) — wrap in a model scope or service object
- Flag controllers that directly manipulate multiple models — extract to a service object
- Flag `before_action` callbacks containing business logic — move to a service or model
- Flag private methods in controllers that aren't directly related to request/response flow — these belong in services, models, or concerns

**Fat models, skinny controllers**:
- Business rules and validations belong in models
- Cross-model orchestration belongs in service objects (e.g., `app/services/`)
- Flag query logic in controllers — use scopes or query objects instead
- Flag controllers building complex data structures — use presenters, decorators, or serializers

**Service objects**:
- Flag service objects that do too many things — one service, one responsibility
- Services should have a single public entry point (e.g., `call`, `perform`, `execute`)
- Flag services that inherit from `ActiveRecord::Base` or include model concerns — services are plain Ruby objects

**Callbacks**:
- Flag `after_save` / `after_create` callbacks that trigger side effects (emails, external APIs, enqueuing jobs) — use service objects instead
- Callbacks should only handle internal model consistency (setting defaults, normalizing data)
- Flag long callback chains — they make flow hard to follow and test

**Strong parameters**:
- Flag `params.permit!` — never permit all params
- Flag strong params defined outside the controller's private section
- Flag overly permissive params (permitting attributes not used by the action)

**N+1 queries**:
- Flag `.each` loops accessing associations without `includes` / `preload` / `eager_load`
- Flag controller actions loading associations that should be eager-loaded in the query

**Boolean method naming**:
- Flag boolean predicate methods using `has_*?` prefix (e.g. `has_admin?`, `has_idp?`) — Ruby convention is to use plain `?` suffix without `has_` prefix (e.g. `admin?`, `idp?`). The `has_` prefix is a Java/JS convention that doesn't belong in idiomatic Ruby.

**Routing & REST**:
- Flag non-RESTful custom actions when a nested resource or new controller would be cleaner
- Flag controllers with more than the 7 RESTful actions — split into multiple controllers

**Security** *(Rails-specific — supplement to `security.md`, do not re-flag items already covered universally)*:
- Flag `find(params[:id])` without scoping to current user/tenant — use `current_user.resources.find(params[:id])` or equivalent authorization
- Flag raw SQL with string interpolation — use parameterized queries or ActiveRecord methods
- Flag `skip_before_action :verify_authenticity_token` without strong justification (API-only endpoints are OK)
- Flag `system()`, backticks, `Open3`, `IO.popen` with interpolated user input — command injection
- Flag `Marshal.load` / `YAML.load` / `YAML.unsafe_load` with untrusted data — deserialization leading to RCE
- Flag `redirect_to params[...]` without URL validation — open redirect
- Flag `permit` including sensitive fields (`:role`, `:admin`, `:verified`, `:permissions`) — mass assignment escalation
- Flag missing `filter_parameters` for sensitive data (passwords, tokens, card numbers) in logs
- Flag sessions with `secure: false` or `httponly: false` — session hijacking
- Flag `send_file` / `send_data` with user-controlled path — path traversal
- Flag `render inline:` or `render html:` with user data — server-side XSS
- Flag `==` for comparing tokens/secrets — use `ActiveSupport::SecurityUtils.secure_compare` (timing attack)
- Flag `Tempfile` or file operations with user-controlled names without sanitization

**Silent failures**:
- Flag `.save` / `.update` / `.destroy` without checking the return value — these return `false` on failure and silently continue. Use bang versions (`.save!`, `.update!`, `.destroy!`) or explicitly handle the `false` return
- Flag `.save` inside a conditional (`if @record.save`) that has no `else` branch — the failure path is silently swallowed

**Transaction safety**:
- Flag multi-model writes (2+ `create`/`update`/`destroy` calls) without `ActiveRecord::Base.transaction {}` — partial writes corrupt data
- Flag `transaction` blocks that call external services (HTTP, email, job enqueue) — side effects can't be rolled back; move them after the transaction

**Background jobs**:
- Flag jobs that receive ActiveRecord objects as arguments instead of IDs — objects can't be reliably serialized/deserialized across retries; pass IDs and re-fetch
- Flag jobs performing non-idempotent side effects (charging, sending emails, creating records) without idempotency guards — jobs retry on failure, causing duplicates
- Flag `perform` methods without error handling for expected failures (network errors, record not found) — unhandled exceptions trigger infinite retries depending on the adapter

**Data leakage**:
- Flag `render json: @model` or `render json: @collection` without a serializer, `only:`, or `except:` — exposes all attributes including sensitive ones (`password_digest`, `api_key`, `reset_token`)
- Flag `to_json` / `as_json` overrides that include sensitive attributes

**Query performance**:
- Flag `.each` / `.map` / `.select` on unbounded ActiveRecord scopes (no `limit`, no `find_each`) — loads entire table into memory; use `find_each` / `in_batches` for large datasets
