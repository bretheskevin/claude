## JavaScript Best Practices (Rails monolith)

**Modern JS**:
- Flag `var` — use `const` (default) or `let` (only when reassignment is needed)
- Flag `==` / `!=` — use strict equality (`===` / `!==`) to avoid type coercion bugs
- Flag string concatenation with `+` — use template literals
- Flag `arguments` object — use rest parameters (`...args`)
- Flag `for (var i` loops over arrays — use `for...of`, `.forEach()`, or `.map()`
- Flag `function` keyword for callbacks — use arrow functions (unless `this` binding is needed)
- Flag CommonJS `require()` when ES modules (`import`/`export`) are supported by the bundler

**jQuery modernization**:
- Flag `$.ajax` / `$.get` / `$.post` — use `fetch()` or Rails UJS `Rails.ajax`
- Flag `$(document).ready()` — use `DOMContentLoaded` or Turbo/Turbolinks events
- Flag `$.each()` — use native `Array.prototype.forEach()` or `for...of`
- Flag `$(selector).hide()` / `.show()` / `.toggle()` — use CSS classes with `.classList.toggle()`
- Flag `$(selector).attr()` / `.prop()` — use native `element.getAttribute()` / properties
- Flag jQuery for simple DOM queries — use `document.querySelector()` / `querySelectorAll()`
- Exception: keep jQuery if the code interacts with a jQuery plugin (e.g., Summernote, Select2, DataTables)

**DOM & events**:
- Flag `addEventListener` without corresponding cleanup — memory leaks, especially in Turbo/SPA contexts
- Flag `document.write()` — breaks document in async contexts, security risk
- Flag inline event handlers in JS-generated HTML (`onclick="..."`) — use `addEventListener`
- Flag direct DOM manipulation in loops without fragment/batch — use `DocumentFragment` or batch updates
- Flag `innerHTML` with user-provided data — XSS risk; use `textContent` or sanitize

**Global scope**:
- Flag top-level `var` / `let` / `const` outside a module or IIFE — global namespace pollution
- Flag assignment to `window.*` unless explicitly registering a public API
- Flag implicit globals (assignment without declaration)

**Security**:
- Flag `eval()` or `new Function()` — code injection risk
- Flag `innerHTML` / `outerHTML` with dynamic content — use `textContent` or sanitize
- Flag `setTimeout` / `setInterval` with string argument — same as eval
- Flag URLs built from user input without validation — open redirect / injection risk

**Error handling**:
- Flag empty `catch` blocks — at minimum log the error
- Flag `catch` that swallows and silences errors without re-throwing or reporting
- Flag missing `.catch()` on Promises — unhandled rejection

**Async patterns**:
- Flag nested callbacks (3+ levels) — use Promises or async/await
- Flag mixing `.then()` and `async/await` in the same function — pick one style
- Flag `async` function that never `await`s — unnecessary async wrapper

**Rails integration**:
- Flag Turbo/Turbolinks-unaware code (caching DOM references at module level that go stale on navigation)
- Flag CSRF token absence in manual fetch/XHR calls — include `X-CSRF-Token` header or use Rails UJS
- Flag hardcoded API paths — use `data-` attributes or Rails route helpers to pass URLs to JS

**Dead code & hygiene**:
- Flag `console.log` / `console.debug` / `debugger` left in production code
- Flag commented-out code blocks — remove or explain
- Flag unused variables and function parameters
- Flag unreachable code after `return` / `throw`
