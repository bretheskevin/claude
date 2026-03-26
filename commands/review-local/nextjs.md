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
