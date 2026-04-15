## State Management Best Practices

**Selector optimization** (Zustand-specific):
- **Multiple individual selectors**: Flag components calling `useStore((s) => s.x)` 3+ times separately. Use `useShallow` from `zustand/react/shallow` to batch them:
  ```tsx
  // Bad: 5 subscriptions, re-renders on any state change
  const a = useStore((s) => s.a);
  const b = useStore((s) => s.b);

  // Good: 1 subscription, shallow comparison
  const { a, b } = useStore(useShallow((s) => ({ a: s.a, b: s.b })));
  ```

**Actions extraction** (Zustand-specific):
- **Actions in reactive selectors**: Actions (functions) don't need reactive subscriptions. Extract them via `getState()`:
  ```tsx
  // Bad: creates unnecessary subscription
  const pause = usePlayerStore((s) => s.pause);

  // Good: stable reference, no subscription
  const actions = () => usePlayerStore.getState();
  // Then: onClick={() => actions().pause()}
  ```

**Derived selector hooks**:
- If multiple components select the same subset of state, create a colocated hook in the store file.

**Cross-store dependencies**:
- Flag direct `otherStore.getState()` calls inside store actions — these can cause subtle bugs. Prefer passing values explicitly or using middleware.

**Persist middleware** (if used):
- Verify `partialize` excludes transient state (loading flags, errors)
- Verify `onRehydrateStorage` handles errors gracefully
