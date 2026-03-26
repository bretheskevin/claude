## Forms (React Hook Form + Zod + shadcn/ui)

**Schema design**:
- Flag manually defined TypeScript interfaces that duplicate a Zod schema — use `z.infer<typeof schema>` as single source of truth
- Flag copy-pasted schemas with overlapping fields — compose with `.extend()`, `.pick()`, `.omit()`, or `.merge()`. Prefer `.extend()` over `.merge()` when adding fields (returns full `ZodObject` with method access)
- Flag `.partial()` applied to nested objects expecting deep partial — `.partial()` only affects top-level keys; handle nested optionality explicitly
- Flag `z.union()` for forms with a discriminator field (e.g. type selector) — use `z.discriminatedUnion("type", [...])` for better error messages and type narrowing
- Flag async Zod refinements that call external APIs on every keystroke — reserve async validation for submit/blur

**React Hook Form performance**:
- Flag `watch()` usage — use `useWatch()` in isolated child components to prevent full-form re-renders
- Flag `formState` destructured at root component level — use `useFormState()` hook in child components to subscribe to specific properties (`errors`, `isSubmitting`, `isDirty`)
- Flag `methods` object (from `useForm()`) passed into `useEffect`/`useCallback`/`useMemo` dependency arrays — destructure specific stable functions (`reset`, `setValue`, `getValues`) instead
- Flag `useState` used to mirror input values already managed by RHF — let RHF manage state via refs; use `Controller` only for components requiring controlled input (Select, DatePicker, Combobox)

**Validation & error handling**:
- Flag `mode: "onChange"` on complex forms with many fields — use `"onBlur"` or `"onTouched"` for better UX and performance
- Flag client-only validation without server-side validation — always validate on both sides with the same shared Zod schema
- Flag server-side errors not mapped back to form fields — use `setError()` to propagate server errors inline alongside client errors
- Flag missing `<FormMessage />` on shadcn form fields — it auto-renders field errors with proper `aria-describedby`

**Field arrays (`useFieldArray`)**:
- Flag array index used as React `key` in field arrays — must use `field.id` from `useFieldArray` to prevent state corruption on reorder/delete
- Flag multiple `useFieldArray` hooks registered with the same `name` — each must be unique
- Flag synchronously stacked field array actions (append/remove/move) — they are batched asynchronously

**Multi-step / wizard forms**:
- Flag a single monolithic schema for multi-step forms — define per-step schemas and merge for the combined type; use `trigger()` to validate only current step fields before advancing
- Flag prop-drilling form methods through step components — use `FormProvider` + `useFormContext()` instead
- Flag `type="submit"` on non-final step buttons — only the last step's submit button should trigger form submission

**Architecture**:
- Flag forms with 3+ fields using raw `useState` instead of RHF — the overhead of manual state, validation, and error wiring exceeds RHF setup cost
- Flag `useFormContext()` consumers not wrapped in `React.memo` — prevents unnecessary re-renders in large forms split across components

**Testing**:
- Flag form tests that assert on RHF internal state — test from the user's perspective (fill fields, submit, assert on visible output)
- Flag `getByTestId` used to query form fields — use role-based queries (`getByRole("textbox")`, `getByRole("button")`) with accessible names
- Flag missing async handling in form submission tests — RHF validation is async, use `waitFor` / `find*` queries
