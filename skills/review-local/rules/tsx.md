## React / TSX Best Practices

**Component design:**
- Flag components over ~150 lines — split into smaller, focused components
- Flag components accepting more than 5-6 props — consider composition, compound component pattern, or a Zustand store
- Flag prop drilling through 3+ levels — lift state to a Zustand store or use composition (children pattern)
- Flag boolean props that control rendering branches (`isAdmin && isEditor && isOwner`) — extract into separate components or a role-based render util
- Flag inline object/array literals as props (`style={{...}}`, `options={[...]}`) — extract to constants or `useMemo` to avoid unnecessary re-renders
- Flag components rendering both layout and logic — separate container (logic) from presentational (UI) when complexity warrants it

**State placement decision tree** (use this to flag misplaced state):

| State type | Where |
|---|---|
| Local to one component | `useState` / `useReducer` |
| URL-representable (filters, pagination, tabs, modals, sort) | nuqs (`useQueryState`) |
| Shared across 2+ unrelated components | Zustand store |
| Server cache (API responses) | TanStack Query / SWR / Server Components |
| Scoped to a subtree, rarely changes | Composition (children pattern) |

- Flag `useState` for state shared across 2+ unrelated components — move to a Zustand store
- Flag state that could be a URL param (filters, pagination, sort, active tab, open modal) — use nuqs, not `useState` or Zustand
- Flag `React.createContext` for global/shared state — use Zustand instead; Context is only tolerated when imposed by a third-party library
- Flag Context used for state that updates frequently — Context re-renders all consumers on every change; use Zustand's selector pattern
- Flag `useState` for complex state objects with interdependent transitions — use `useReducer`
- Flag duplicated state (same data in two `useState` calls) — derive one from the other
- Flag global state used for server cache (API responses stored in Zustand) — use TanStack Query/SWR for server state

**Hooks discipline:**
- Flag `useEffect` with missing or incorrect dependency arrays — exhaustive deps required
- Flag `useEffect` used for derived state (computing value from props/state) — use `useMemo` or compute during render
- Flag `useEffect` used to sync state (`setState` inside `useEffect` watching another state) — derive instead of sync
- Flag `useState` + `useEffect` for fetched data — use a data-fetching library (TanStack Query, SWR) or Server Components
- Flag custom hooks that don't start with `use` prefix
- Flag custom hooks that do too many things — one hook, one responsibility
- Flag `useCallback`/`useMemo` wrapping trivial expressions (a string concat, a boolean check) — only memoize when there's a measurable cost
- Flag missing `useCallback` on functions passed as props to memoized children (`React.memo`)
- Flag `useRef` used as a `useState` replacement when the component needs to re-render on value change
- Flag `useEffect` with an empty dependency array used as "on mount" when the real intent is data fetching — use a data-fetching library or Server Component

**"You Might Not Need an Effect" — flag these unnecessary Effect patterns:**
- Flag `useEffect` that resets state when a prop changes (e.g. `useEffect(() => { setState(''); }, [propId])`) — use a `key` prop on the component instead to force React to remount with fresh state
- Flag `useEffect` that adjusts partial state on prop change when the state can be derived — store the selected ID, not the selected item; compute during render: `const selection = items.find(i => i.id === selectedId) ?? null`
- Flag chained `useEffect`s that each update state based on another state (cascading state updates) — compute what you can during render, and batch remaining updates in the event handler that triggered the change
- Flag `useEffect` containing event-specific logic (user clicks, form submits, drag events) — if code runs because the user *did something*, it belongs in the event handler, not in an Effect. Effects are for synchronizing with external systems *because the component is displayed*
- Flag `useEffect` that notifies a parent component about state changes (e.g. calling `onChange(value)` inside `useEffect(() => { onChange(isOn) }, [isOn])`) — call the parent callback directly in the same event handler that updates the state, so both updates batch in one render pass
- Flag child component using `useEffect` to pass fetched data to parent via callback prop — lift the data fetching to the parent and pass data down as props; keep data flow top-down
- Flag manual event listener subscriptions in `useEffect` for external stores (e.g. `addEventListener('online', ...)`) — use `useSyncExternalStore` instead
- Flag `useEffect` with `fetchData` that has no cleanup/ignore flag for race conditions — if keeping a fetch in an Effect, always return a cleanup function with an `ignore` boolean to discard stale responses. Better: use a data-fetching library

**"You Might Not Need useCallback/useMemo" — flag these unnecessary memoization patterns:**
- Flag `useCallback` on functions passed to plain DOM elements (`<button onClick={handleClick}>`) — DOM elements don't benefit from stable references, they always re-render with parent
- Flag `useCallback` on functions passed to non-memoized children — if child is not wrapped in `React.memo`, stable reference achieves nothing; child re-renders anyway
- Flag `useMemo` for trivial computations (string concat, boolean check, simple arithmetic) — memoization overhead exceeds computation cost
- Flag `useCallback`/`useMemo` with broken memoization chains — one value memoized but another prop to same child creates new object/array each render, invalidating the optimization
- Flag reflexive "wrap everything" memoization — each hook adds overhead (function call, dependency comparison, cache storage). Default to no memoization; add only when justified
- Flag `useMemo` used as semantic marker ("this is derived") when computation is cheap — just compute during render: `const fullName = first + ' ' + last`

**When useCallback/useMemo ARE required:**
- `useCallback` for functions passed as props to `React.memo`-wrapped children — stable reference prevents child re-render
- `useCallback` for functions used in dependency arrays of `useEffect`/`useMemo`/other hooks — prevents unnecessary re-execution
- `useMemo` for expensive computations (filtering/sorting large lists, complex transforms) — verify with profiler first
- `useMemo` for stabilizing object/array references passed to `React.memo`-wrapped children — new reference = child re-render

**TypeScript strictness:**
- Flag `any` type — must use proper types, `unknown`, or generics
- Flag type assertions (`as Type`) — prefer type guards or narrowing
- Flag missing return types on exported functions/components
- Flag `interface` vs `type` inconsistency within the same codebase — pick one convention and stick to it
- Flag non-discriminated unions where a discriminant field would make exhaustive matching possible
- Flag `!` non-null assertions — prefer optional chaining or explicit null checks
- Flag `// @ts-ignore` or `// @ts-expect-error` without an explanation comment
- Flag `enum` — prefer `as const` objects or union types (enums have runtime quirks and bloat bundles)
- Flag `Object` / `Function` / `{}` as types — use specific types (`Record<string, unknown>`, `() => void`, `Record<string, never>`)

**JSX patterns:**
- Flag index as `key` in lists where items can be reordered, added, or removed
- Flag nested ternaries in JSX — extract to early returns, variables, or a helper component
- Flag `&&` short-circuit rendering with numbers (`count && <Foo />`) — use `count > 0 &&` or ternary (0 renders as text)
- Flag string concatenation for classNames — use `clsx` or `cn()` utility
- Flag inline anonymous functions in JSX event handlers that contain non-trivial logic (>1 line) — extract to named handlers
- Flag spreading `{...props}` without an explicit type — leaks unknown props to DOM elements
- Flag `dangerouslySetInnerHTML` without sanitization
- Flag hardcoded strings in UI — should use i18n (if i18n is set up in the project)

**Error handling:**
- Flag missing `ErrorBoundary` around async/dynamic sections
- Flag `try/catch` that silently swallows errors (empty catch or only `console.log`)
- Flag missing user-facing error feedback after catch — users must know something went wrong

**Testing:**
- Flag testing implementation details (checking state values, internal method calls) — test behavior/output instead
- Flag `fireEvent` when `userEvent` is available — more realistic user simulation
- Flag snapshot tests for complex components — prefer explicit assertions
- Flag mocking modules that could be injected as props/context
