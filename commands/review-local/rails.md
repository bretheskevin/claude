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

**Routing & REST**:
- Flag non-RESTful custom actions when a nested resource or new controller would be cleaner
- Flag controllers with more than the 7 RESTful actions — split into multiple controllers

**Security**:
- Flag `find(params[:id])` without scoping to current user/tenant — use `current_user.resources.find(params[:id])` or equivalent authorization
- Flag raw SQL with string interpolation — use parameterized queries or ActiveRecord methods
- Flag `skip_before_action :verify_authenticity_token` without strong justification (API-only endpoints are OK)
