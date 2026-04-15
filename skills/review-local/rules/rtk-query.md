## RTK Query Best Practices (Generated API from Swagger/OpenAPI)

**Code generation & base API**:
- Flag manually written endpoint definitions that duplicate what the code generator produces — generated hooks are the source of truth; extend via `enhanceEndpoints()` or `injectEndpoints()`, never edit the generated file directly
- Flag generated API files checked into VCS without a regeneration script — ensure a `generate` or `codegen` npm script exists so the team can regenerate deterministically
- Flag `baseQuery` without `prepareHeaders` when auth is required — inject auth tokens (Bearer, cookies) in `prepareHeaders` on the base API, not per-endpoint
- Flag multiple `createApi()` calls sharing the same `reducerPath` — each API slice must have a unique `reducerPath` to avoid state collisions

**Using generated hooks**:
- Flag raw `useQuery` / `useMutation` imports from `@reduxjs/toolkit/query/react` instead of the generated typed hooks — always import from the generated API file (e.g., `useGetUsersQuery`, `useUpdateUserMutation`)
- Flag `useQuery` results destructured without handling `isLoading`, `isError`, and `error` — always handle all three states; use `isUninitialized` when the query is conditional
- Flag `skip: someCondition` combined with non-null assertions on `data` — when `skip` is true, `data` is `undefined`; guard accordingly

**Cache & invalidation**:
- Flag mutations without `invalidatesTags` — every mutation that changes server state should invalidate the relevant cache tags to keep the UI in sync
- Flag overly broad tag invalidations (e.g., invalidating an entire entity type on a single-item update) — use `{ type, id }` tags for targeted invalidation instead of just `{ type }`
- Flag `providesTags` returning a flat `[Type]` instead of per-item tags — list endpoints should return `[...items.map(({ id }) => ({ type, id })), { type, id: 'LIST' }]` for granular cache invalidation
- Flag manual `refetch()` calls right after a mutation — use `invalidatesTags` / `providesTags` for automatic refetching; manual refetch breaks the declarative cache model

**Transforming responses**:
- Flag data transformation done in components instead of `transformResponse` — normalize or reshape API responses in the endpoint's `transformResponse` to keep components clean
- Flag `transformResponse` that mutates the response object — always return a new object
- Flag `selectFromResult` returning new object references on every render — memoize with `createSelector` or return stable primitives to avoid unnecessary re-renders

**Optimistic updates & manual cache**:
- Flag `updateQueryData` (optimistic update) without an `onQueryStarted` error rollback — always `undo()` via `patchResult.undo()` in the catch block
- Flag `updateQueryData` used for simple invalidation scenarios — prefer `invalidatesTags` over manual cache writes unless you need instant UI feedback

**Polling & streaming**:
- Flag `pollingInterval` set without a corresponding `skipPollingIfUnfocused: true` — avoid unnecessary network traffic when the tab is inactive
- Flag WebSocket/SSE data manually dispatched to the store instead of using `onCacheEntryAdded` — RTK Query's streaming update lifecycle handles connection cleanup automatically

**Performance**:
- Flag components subscribing to the same query with different `selectFromResult` — extract a shared hook or use `createSelector` to avoid duplicate subscriptions
- Flag `refetchOnMountOrArgChange: true` set globally on `createApi` — prefer per-endpoint or per-hook usage to avoid excessive refetching
- Flag `keepUnusedDataFor: 0` set globally — only disable caching for specific volatile endpoints, not the entire API

**Type safety**:
- Flag type assertions (`as`) on query/mutation results — the generated types from the Swagger should be accurate; if they're wrong, fix the schema or use `transformResponse` with proper typing
- Flag `any` used in `onQueryStarted`, `transformResponse`, or `selectFromResult` — these should be fully typed from the generated schema
- Flag hand-written request/response types that duplicate generated ones — import types from the generated API file or the shared types module

**Architecture**:
- Flag API calls made outside RTK Query (raw `fetch`/`axios`) for endpoints already defined in the generated API — use the generated hooks for consistency and caching
- Flag business logic in `onQueryStarted` that should be in a thunk or slice — `onQueryStarted` is for cache side effects, not domain logic
- Flag components calling 5+ query hooks — consider composing queries in a custom hook or restructuring the component tree so each child owns its data dependency
