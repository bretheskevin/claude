## Angular Best Practices

**Control flow (built-in)**:
- Flag `*ngIf`, `*ngFor`, `*ngSwitch` — must use built-in `@if`, `@for`, `@switch` control flow blocks
- `@for` requires a `track` expression — flag missing `track`
- Flag `<ng-container>` used solely to host a structural directive — `@if`/`@for` eliminates the need

**Signals**:
- Flag `BehaviorSubject` / `ReplaySubject` used as component state — prefer `signal()` / `computed()` / `effect()`
- Flag `@Input()` decorator — prefer `input()` / `input.required()` signal inputs
- Flag `@Output()` with `EventEmitter` — prefer `output()` function
- Flag `@ViewChild` / `@ViewChildren` — prefer `viewChild()` / `viewChildren()` signal queries
- Flag `ngOnChanges` used to derive state from inputs — use `computed()` over signal inputs instead
- Flag `ChangeDetectionStrategy.Default` — prefer `ChangeDetectionStrategy.OnPush` (or `zoneless` if project uses it)

**Dependency injection**:
- Flag constructor-based injection — prefer `inject()` function
- Flag `providedIn: 'root'` on services that are only used in one module — scope them appropriately

**Reactive patterns**:
- Flag `subscribe()` in components without cleanup — prefer `toSignal()`, `async` pipe, or `takeUntilDestroyed()`
- Flag manual `ngOnDestroy` for subscription cleanup — prefer `DestroyRef` + `takeUntilDestroyed()`

**Standalone components**:
- Flag `declarations` in `NgModule` — prefer standalone components with `imports` directly on the component
- Flag `standalone: false` or missing `standalone: true` — all new components should be standalone
