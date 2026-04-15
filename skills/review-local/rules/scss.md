## SCSS / CSS Best Practices

**Bootstrap compliance (project-specific)**:
- Flag any Tailwind classes (`tw-*` prefixes) — Bootstrap only
- Flag inline `style=""` attributes — use Bootstrap utility classes
- Flag custom CSS when a Bootstrap utility class exists (margins, padding, display, flex, text alignment, visibility)
- Flag custom grid/layout CSS — use Bootstrap grid system (`row`, `col-*`, `container`)
- Flag custom breakpoint media queries when Bootstrap responsive classes exist (`d-md-none`, `col-lg-6`, etc.)

**Specificity & structure**:
- Flag nesting deeper than 3 levels — flatten with BEM or utility classes
- Flag `!important` without justification — specificity arms race; must be commented if truly needed
- Flag overly qualified selectors (`div.container > ul.list > li.item`) — keep selectors short and specific
- Flag ID selectors (`#my-element`) for styling — use classes; IDs are for JS hooks and anchors
- Flag `*` (universal selector) in non-reset contexts — performance and specificity issues

**Variables & consistency**:
- Flag hardcoded color values (`#fff`, `rgb(...)`, `hsl(...)`) — use SCSS variables or Bootstrap color variables (`$primary`, `$danger`, etc.)
- Flag hardcoded spacing values — use SCSS variables or Bootstrap spacing scale (`$spacer`, `map-get($spacers, 3)`)
- Flag hardcoded font-size in `px` — use `rem`, SCSS variables, or Bootstrap font-size utilities
- Flag hardcoded `z-index` magic numbers — use a z-index variable scale
- Flag hardcoded `border-radius` values — use Bootstrap variables (`$border-radius`, `$border-radius-lg`)

**Modern Sass**:
- Flag `@import` — use `@use` / `@forward` (avoids duplication, enables namespacing)
- Flag vendor prefixes in source (`-webkit-`, `-moz-`, `-ms-`) — rely on autoprefixer
- Flag `@extend` on non-placeholder selectors — causes selector bloat; prefer mixins or utility classes
- Flag deeply nested `&` parent selectors that produce unreadable compiled output

**DRY & maintainability**:
- Flag duplicated property blocks across selectors — extract to a mixin or shared class
- Flag repeated media queries with identical breakpoints — group or use a mixin
- Flag component styles that duplicate existing global/shared styles — reuse existing classes

**Layout anti-patterns**:
- Flag `float` for layout — use Bootstrap grid or flexbox utilities
- Flag `position: absolute` / `fixed` without a positioned ancestor context — layout bugs
- Flag negative margins as layout fixes — usually a sign of a structural problem
- Flag `width: 100vw` — causes horizontal scrollbar when scrollbar is visible; use `width: 100%`

**Performance**:
- Flag `@import` of the same file in multiple places — duplication in compiled output
- Flag wildcard selectors in complex rules (`[class*="col-"]`) — slow selector matching
- Flag large `box-shadow` / `filter` on frequently re-rendered elements — GPU compositing cost

**Dead code**:
- Flag empty rule blocks — remove them
- Flag commented-out CSS blocks — remove or explain why kept
- Flag classes/selectors that don't match any markup in the changed files (when verifiable)
