## SQL & Migrations Best Practices

**Migration safety (production)**:
- Flag `add_column` with `default:` on large tables — locks the table in older PostgreSQL; use `add_column` then `change_column_default` separately
- Flag `remove_column` without verifying the column is unused in code — search for references first
- Flag `rename_column` / `rename_table` in production — these break running code during deploy. Use add-copy-remove strategy.
- Flag irreversible migrations without explicit `down` method — always provide a rollback path or use `reversible`
- Flag `change_column` that narrows a type (e.g., `string` to `integer`, larger to smaller limit) — data loss risk
- Flag `execute` with raw SQL that isn't wrapped in `reversible` — no automatic rollback

**Indexing**:
- Flag `add_reference` / `add_column` for foreign keys without `index: true` — foreign keys almost always need indexes
- Flag `add_index` on large tables without `algorithm: :concurrently` — locks the table. Must use `disable_ddl_transaction!` with it.
- Flag missing composite indexes when queries filter on multiple columns together
- Flag redundant indexes (an index on `[a, b]` already covers queries on `a` alone)

**Constraints & data integrity**:
- Flag columns that should have `null: false` but don't — especially foreign keys, status fields, and required business data
- Flag missing `unique` constraints/indexes for fields that must be unique (email, slug, external IDs)
- Flag missing foreign key constraints (`add_foreign_key`) when `add_reference` is used — referential integrity matters

**Query patterns (in models/scopes)**:
- Flag `where` with string interpolation (`where("col = #{val}")`) — SQL injection. Use parameterized: `where("col = ?", val)` or `where(col: val)`
- Flag `.pluck` followed by Ruby array operations — do the filtering/sorting in SQL instead
- Flag `all.each` or loading entire tables into memory — use `find_each` / `in_batches` for large datasets
- Flag `count` queries inside loops — preload counts with `counter_cache` or `group(:x).count`
- Flag `SELECT *` patterns (implicit in ActiveRecord) when only specific columns are needed — use `.select()` for large tables
