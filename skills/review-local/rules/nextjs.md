## Next.js Best Practices

**Context detection**: Before applying rules below, determine if Next.js owns the backend (has `app/api/` routes, server actions, or DB access) or is frontend-only (calls an external API like Rails, Django, etc.). Check for `'use server'` directives, `app/api/` directories, or ORM imports (`prisma`, `drizzle`, etc.).

**Server vs Client components**:
- Flag `'use client'` on components that don't use hooks, event handlers, or browser APIs — they should be Server Components
- Flag `useState`/`useEffect` in Server Components (missing `'use client'` directive)
- Flag entire page/layout marked `'use client'` — push client boundary down to the smallest interactive subtree

**Data fetching (Next.js owns the backend)**:
- Flag `useEffect` + `fetch` for initial data loading — use Server Components with `async/await` or Server Actions
- Flag `getServerSideProps` / `getStaticProps` (Pages Router patterns in App Router projects) — use the native `fetch` in Server Components with caching options
- Flag missing `revalidate` or cache strategy on `fetch` calls in Server Components

**Data fetching (frontend-only, external API)**:
- Flag `getServerSideProps` / `getStaticProps` (Pages Router patterns in App Router projects) — use Server Components with `async/await` and the native `fetch` with caching options
- Flag missing `revalidate` or cache strategy on `fetch` calls in Server Components
- Flag `useEffect` + `fetch` for initial data loading — prefer fetching in Server Components then passing data as props to client components
- Flag `'use server'` / Server Actions used as a proxy to the external API when a direct Server Component fetch would suffice — Server Actions are for mutations, not read-through proxies

**Server Actions (only when Next.js owns the backend)**:
- Flag Server Actions that don't validate input — always validate with zod or similar
- Flag `'use server'` at file top when only some functions are actions — prefer per-function `'use server'`
- Flag Server Actions that return sensitive data to the client

**Routing & rendering**:
- Flag missing `loading.tsx` for routes with async data — use Suspense boundaries
- Flag missing `error.tsx` for routes that can fail
- Flag `useRouter` from `next/router` — must use `next/navigation` in App Router
- Flag `<a>` tags — must use `<Link>` from `next/link`
- Flag `<img>` tags — must use `<Image>` from `next/image`
- Flag custom layout wrapper components (e.g. `SiteLayout`, `AppLayout`) in `components/` that should be Next.js `layout.tsx` files in the `app/` directory — use the built-in nested layout system instead of component wrappers for shared chrome (navbar, footer, sidebar)

**Query params**:
- Flag `useSearchParams()` or manual `URLSearchParams` for reading/writing query params — must use [nuqs](https://nuqs.dev/docs/installation) instead
- Flag query param state managed via `useState` + URL sync — use `useQueryState` / `useQueryStates` from nuqs for type-safe, URL-synced state
- Flag missing parser (e.g. `parseAsString`, `parseAsInteger`) when using nuqs — always specify the appropriate parser for type safety

**Metadata & SEO**:
- Flag hardcoded `<title>` / `<meta>` — use `metadata` export or `generateMetadata()` in App Router
- Flag missing `metadata` in page/layout files

**Performance**:
- Flag large client bundles — check for heavy libraries imported in `'use client'` components that could be loaded server-side or dynamically
- Flag missing `dynamic()` import for heavy client components not needed at first paint
- Flag `next/dynamic` without `ssr: false` when the component truly needs client-only rendering

**Forms (only when Next.js owns the backend)**:
- Flag form schemas defined only in client code when server actions use the same validation — extract shared schemas into a common module importable by both client and server
- Flag async Zod refinements that call external APIs on every keystroke — reserve async validation for submit/blur via server actions

**Parallel routes & intercepting routes**:
- Flag modal implementations using client-side state (`useState` to show/hide) when an intercepting route (`(.)`, `(..)`) would give URL-shareable modals with proper back-button behavior
- Flag missing `default.tsx` in parallel route slots — Next.js needs it to know what to render when the slot isn't active

**Caching & revalidation (App Router)**:
- Flag `fetch` in Server Components without explicit `cache` or `next.revalidate` option — always be intentional about caching
- Flag `revalidatePath`/`revalidateTag` called without corresponding `tags` on fetch calls — the revalidation will have no effect
- Flag `cache: 'no-store'` on every fetch — only use for truly dynamic data; default to caching with revalidation
- Flag missing `unstable_cache` (or equivalent) around direct DB queries — `fetch` auto-caches but raw DB calls don't

**Middleware**:
- Flag heavy computation or data fetching in `middleware.ts` — middleware runs on every request at the edge; keep it thin (auth checks, redirects, rewrites only)
- Flag `middleware.ts` not using `matcher` config — without it, middleware runs on every request including static assets
- Flag cookies/headers manipulation in middleware without considering edge runtime limitations

**Server Components advanced**:
- Flag `async` client components — only Server Components can be `async`
- Flag passing non-serializable props (functions, class instances, Dates) from Server to Client components — the boundary only supports JSON-serializable data
- Flag importing a Client Component that receives children without understanding the composition model
- Flag `headers()`, `cookies()` in components that could be statically rendered — these opt the entire route into dynamic rendering

**Route handlers (`app/api/`)**:
- Flag missing input validation in Route Handlers
- Flag Route Handlers that don't return proper HTTP status codes (always 200)
- Flag Route Handlers without proper `Content-Type` headers
- Flag `GET` Route Handlers with side effects — GET should be safe/idempotent

**Security**:
- Flag Server Actions callable without auth checks — every Server Action is a public endpoint
- Flag `redirect()` using user-supplied URLs without validation — open redirect vulnerability
- Flag missing CSRF protection on mutation endpoints

**Component organization**:
- Flag site-wide components (navbar, footer, locale switcher, brand) placed inside a page-specific directory (e.g. `components/landing/`) — shared components must live in a shared directory (e.g. `components/site/`) so the import path reflects their actual scope
- Do NOT flag multiple components defined in a single file when the helper components are private (not exported) and only used by the main exported component in that file — this is standard React practice. Only flag if a non-exported component is complex enough to warrant its own file (e.g. has its own state, effects, or is 50+ lines) or if multiple components are exported from the same file (breaks one-exported-component-per-file convention)

**Bundle & imports**:
- Flag `moment.js` — use `date-fns` or `Intl` APIs (moment is 300KB+)
- Flag `lodash` full import (`import _ from 'lodash'`) — use cherry-picked imports (`import debounce from 'lodash/debounce'`) or native equivalents
- Flag barrel file imports (`import { X } from '@/components'`) in client components — barrel files defeat tree-shaking and bloat the client bundle
- Flag `'use client'` in a barrel/index file — it makes everything exported from it a client component

**Streaming & Suspense**:
- Flag missing `<Suspense>` boundaries around slow async Server Components — without them the entire page blocks
- Flag `loading.tsx` without a meaningful skeleton/placeholder — just a spinner is lazy UX for data-heavy pages
- Flag sequential `await` for independent data fetches in Server Components — use `Promise.all` to parallelize

**Environment variable exposure**:
- Flag secrets (API keys, database URLs, auth secrets) in `NEXT_PUBLIC_*` environment variables — these are inlined into the client JS bundle and visible in browser devtools
- Flag `process.env.NEXT_PUBLIC_*` used to hold tokens, passwords, or connection strings — only non-sensitive config (API base URLs, feature flags, public keys) should use the `NEXT_PUBLIC_` prefix
