## ERB / Rails Views Best Practices

**Zero logic in views**:
- Flag conditionals beyond simple display toggling (`if @user.admin?` is OK, `if @user.role == "admin" && @user.verified? && !@user.suspended?` is not) — extract to a helper or presenter method
- Flag loops with inline transformations (`.map`, `.select`, `.reject` in ERB) — prepare data in the controller or presenter
- Flag calculations or formatting logic — move to helpers (`number_to_currency`, `time_ago_in_words`) or decorators
- Flag direct model method calls that compute/derive data — use presenter/decorator pattern

**Security** *(ERB-specific — supplement to `security.md`, do not re-flag items already covered universally)*:
- Flag `raw()` or `.html_safe` without clear justification — XSS risk. Every usage must be audited.
- Flag `<%== %>` (unescaped output) — same as `raw`, must be justified
- Flag user-provided data rendered without sanitization — use `sanitize()` helper when HTML is intentional
- Flag `link_to` with user-controlled URLs without protocol validation — `javascript:` injection risk

**Partials & DRY**:
- Flag repeated markup blocks (3+ lines appearing 2+ times) — extract to a partial
- Flag partials with 5+ local variables — too coupled, consider a presenter or restructure
- Flag deeply nested partial rendering (partial renders partial renders partial) — flatten the hierarchy
- Flag inline HTML that duplicates an existing partial — reuse existing partials

**Performance**:
- Flag `render partial:` inside loops without `collection:` — use `render collection:` for automatic optimization
- Flag N+1 patterns: accessing associations in views that weren't eager-loaded in the controller/query
- Flag heavy computation in views (sorting, grouping large collections) — do this in the controller

**Accessibility & HTML quality**:
- Flag images without `alt` attributes
- Flag form inputs without associated `<label>` elements
- Flag non-semantic HTML (`<div>` used as button, `<span>` used as heading) — use proper elements
- Flag missing ARIA attributes on interactive custom components

**I18n**:
- Flag hardcoded user-facing strings — use `t()` / `I18n.t()` for all text visible to end users
- Exception: internal admin tools can use hardcoded strings if i18n is not required

**Bootstrap compliance** (project-specific):
- Flag any Tailwind classes (`tw-*` prefixes) — Bootstrap only
- Flag inline `style=""` attributes — use Bootstrap utility classes
- Flag custom CSS when a Bootstrap utility class exists (margins, padding, display, flex)
