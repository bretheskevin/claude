## RSpec Best Practices

**Test structure**:
- Flag specs without `described_class` — always reference the class under test via `described_class`, not the hardcoded class name
- Flag missing `context` blocks when a single `describe` has multiple scenarios — group by precondition (`context "when user is admin"`)
- Flag deeply nested `context` blocks (4+ levels) — extract to shared examples or separate spec files
- Flag specs testing multiple behaviors in one `it` block — one expectation per test (or closely related expectations)

**Factories & data setup**:
- Flag `let!` when `let` (lazy) would suffice — `let!` forces evaluation even when unused in some examples
- Flag inline `create()` / `build()` with many attributes — use factory traits instead (`create(:user, :admin)` not `create(:user, role: "admin", verified: true, ...)`)
- Flag `before(:all)` / `before(:context)` — data leaks between examples; use `before(:each)` or `let`
- Flag tests creating more records than needed — minimal data setup only

**Mocking & stubbing**:
- Flag `allow_any_instance_of` — brittle, use dependency injection or specific instance stubs
- Flag mocking the object under test — test real behavior, mock collaborators only
- Flag excessive mocking when an integration test would be more valuable (especially for model specs with DB interactions)

**Matchers & readability**:
- Flag `expect(x).to eq(true)` / `eq(false)` — use `be true` / `be false` or predicate matchers (`be_valid`, `be_empty`)
- Flag `expect(x).not_to be_nil` when a more specific matcher exists (`be_present`, `be_a(String)`)
- Flag `expect { ... }.to change { X }.by(Y)` without testing the before-state when it matters
- Flag string-heavy `it` descriptions that repeat the context — keep `it` blocks short, rely on context for setup description

**Request/controller specs**:
- Flag controller specs testing business logic — that logic should be in model/service specs instead
- Flag request specs without response status assertions — always assert `response.status` or `response.code`
- Flag request specs that don't test error/edge cases (missing params, unauthorized access)

**Shared examples**:
- Flag 3+ specs with identical structure differing only in input/output — extract to `shared_examples`
- Flag shared examples that are too generic or test too many things — one shared example, one behavior

**Performance**:
- Flag specs using `create` when `build` or `build_stubbed` would work (no DB needed)
- Flag missing `DatabaseCleaner` strategy awareness — transaction strategy is fastest for most specs
