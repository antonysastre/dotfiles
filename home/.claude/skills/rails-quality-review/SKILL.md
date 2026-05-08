---
  name: rails-qa-review
  description: Review Rails code for quality and issues
---

Apply the Pragmatic Programmer principles to Rails/Ruby code, but ensure and prioritize to not change behaviour:

1. DRY
   Avoid duplicated business rules, validations, scopes, queries, and view conditionals.
   Do not abstract merely because code looks similar. Extract only when duplication has the same reason to change.

2. Orthogonality
   Keep controllers, models, jobs, mailers, views, and service objects independent.
   Scan the controllers for domain logic that should be in models.
   Make sure change in UI do not alter domain logic.
   Make sure changes doe not alter domain logic they are not responsible for.

3. Don’t Live with Broken Windows
   Flag dead code, unclear names, ignored failing tests, skipped validations, stale comments, TODOs without ownership, and inconsistent conventions.
   Prefer small cleanup when touching nearby code.

4. Don’t Program by Coincidence
   Do not accept code that works accidentally.
   Explain why the Rails callback, scope, transaction, validation, association, or query behaves correctly.
   Avoid sleeps, order-dependent tests, hidden side effects, and unexplained monkey patches.

5. Refactor Early and Often
   Prefer small, behavior-preserving improvements.
   Improve names, extract concepts, simplify branches, and reduce duplication while preserving Rails idioms.
   Do not introduce architecture layers without clear pressure.

6. Crash Early
   Fail close to invalid input or impossible state.
   Prefer explicit errors, validations, database constraints, and guard clauses over silent nil behavior.
   Do not hide failures with broad rescue blocks.

7. Minimize Coupling
   Avoid long object chains, god models, fat controllers, global state, excessive callbacks, and cross-model knowledge leaks.
   Prefer clear public methods that express domain intent.

8. Separate Views from Models
   Keep business rules out of ERB, helpers, serializers, presenters, and frontend conditionals.
   Views should ask meaningful questions such as `order.refundable?`, not calculate refund eligibility.

9. Test Ruthlessly
   Add or update tests for changed behavior.
   Cover happy path, failure path, edge cases, authorization, validations, jobs, mailers, and important integrations.
   For bug fixes, add a regression test.

10. Domain Languages
   Use names from the business domain.
   Prefer `approve_invoice`, `capture_payment`, `schedule_inspection`, `publish_article`.
   Avoid vague names like `process`, `handle`, `perform_stuff`, `data`, `manager`, and `service` unless the domain justifies them.

11. Estimate Algorithmic Cost
   Check for N+1 queries, unbounded `.all`, inefficient Ruby-side filtering, missing indexes, unnecessary object allocation, and memory-heavy batch jobs.
   Prefer database filtering, pagination, batching, eager loading, and proper indexes.

Rails-specific quality checks:
- Follow Rails conventions before adding custom architecture.
- Keep controllers thin: authorize, load, call domain behavior, respond.
- Keep models cohesive: domain behavior belongs near the data, but avoid god models.
- Use service objects only when they clarify a real workflow.
- Prefer database constraints for real invariants: null constraints, foreign keys, unique indexes, check constraints.
- Wrap multi-write business operations in transactions.
- Avoid callbacks for surprising business workflows.
- Avoid broad `rescue StandardError`.
- Avoid `update_all`, `delete_all`, `find_each`, raw SQL, and callbacks bypassing APIs unless intentional and explained.
- Prefer scopes for reusable query concepts, but avoid scopes with hidden side effects.
- Prefer POROs for pure domain logic when Active Record would make the model incoherent.
- Keep migrations reversible and production-safe.
- Check authorization and parameter filtering in controllers.
- Do not introduce gems when plain Rails/Ruby is enough.

When reviewing code, return:

1. Critical correctness issues
2. Rails convention violations
3. Maintainability issues
4. Performance/query issues
5. Test gaps
6. Suggested patch or refactor
