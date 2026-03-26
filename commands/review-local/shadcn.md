## shadcn/ui Best Practices

**Native HTML elements vs shadcn components — flag as issues**:
- Flag `<button` used instead of `<Button` from `@/components/ui/button` — the shadcn Button provides consistent styling, variants, loading states, and accessibility out of the box
- Flag `<input` used instead of `<Input` from `@/components/ui/input` (except inside `ui/input.tsx` itself)
- Flag `<select` used instead of `<Select` from `@/components/ui/select` (except inside `ui/select.tsx` itself)
- Flag `<label` used instead of `<Label` from `@/components/ui/label` (except inside `ui/label.tsx` itself)
- Flag `<textarea` used instead of `<Textarea` from `@/components/ui/textarea` (except inside `ui/textarea.tsx` itself)
- Flag `<dialog` used instead of `<Dialog` from `@/components/ui/dialog` (except inside `ui/dialog.tsx` itself)
- Flag `<input type="checkbox"` used instead of `<Checkbox` from `@/components/ui/checkbox` (except inside `ui/checkbox.tsx` itself)
- Flag `<table`, `<thead`, `<tbody`, `<tr`, `<th`, `<td` used instead of shadcn Table components (except inside `ui/table.tsx` itself)
- **Exception**: files inside `src/components/ui/` and test files (`__test__/`, `.test.tsx`) are allowed to use native elements
- **Exception**: native elements used as non-interactive containers (e.g. `<label>` wrapping a non-form context) can be acceptable — use judgment

**Component availability check**:
- Before flagging a missing shadcn component, verify it exists in `src/components/ui/`. If the project doesn't have a specific shadcn component installed, flag it as a **suggestion** to install it rather than an **issue**
- If the shadcn MCP server is available (`mcp__shadcn__*` tools), use `mcp__shadcn__search_items_in_registries` to check if a needed component exists in the registry and recommend `mcp__shadcn__get_add_command_for_items` for installation

**Variant and size consistency**:
- Flag hardcoded className overrides that duplicate what a variant already provides (e.g. `className="bg-primary text-white"` on a `<Button>` when `variant="default"` already does this)
- Flag inconsistent variant usage for the same semantic action across the app (e.g. destructive actions should consistently use `variant="destructive"`)
- Flag `size="icon"` buttons missing an `aria-label` — icon-only buttons must have accessible labels

**Composition patterns**:
- Flag components re-implementing behavior that shadcn already provides (custom dropdowns, custom tooltips, custom dialogs) — use shadcn primitives
- Flag `cn()` utility not used for conditional className merging — import from `@/lib/utils`
- Flag direct Radix UI primitive imports when a shadcn wrapper exists in the project — use the shadcn component which applies project theming
- Flag inline styles (`style={{}}`) for things achievable with Tailwind classes

**Theming and design tokens**:
- Flag hardcoded color values (`#fff`, `rgb(...)`, `text-blue-500`) instead of semantic CSS variables (`text-primary`, `bg-muted`, `border-border`)
- Flag hardcoded border-radius values instead of using the `rounded-*` classes that map to the project's design tokens
- Flag `dark:` prefixed classes when the component should use CSS variables that auto-adapt to theme (e.g. `text-foreground` instead of `text-black dark:text-white`)

**Accessibility**:
- Flag shadcn Dialog/Sheet/AlertDialog missing required sub-components (`DialogTitle`, `DialogDescription`) — these are required for screen readers
- Flag `Tooltip` used without `TooltipProvider` ancestor
- Flag interactive elements inside `Tooltip` triggers — tooltips should be on non-interactive or simple interactive elements
- Flag `DropdownMenu` or `ContextMenu` items missing keyboard navigation support

**Performance**:
- Flag importing the entire shadcn component file when only a sub-component is needed (e.g. importing all of `select.tsx` for just `SelectItem`)
- Flag `Popover`/`Dialog`/`Sheet` content rendered unconditionally — these should leverage Radix's built-in lazy mounting

**Full codebase scan** (when reviewing branch diff or when explicitly requested):
- Beyond the diff, scan all `.tsx` files outside `src/components/ui/` and test files for native HTML elements that have a shadcn equivalent installed in the project. Use `search_for_pattern` or Grep to find `<button`, `<input`, `<select`, `<textarea`, `<dialog`, `<label` in `.tsx` files. Report these as **suggestions** (not issues) since they're outside the current diff, grouped in a separate "Pre-existing native elements" section after the main review table
