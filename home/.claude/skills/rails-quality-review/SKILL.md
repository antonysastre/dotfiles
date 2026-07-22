---
name: rails-quality-review
description: >
  Review Rails/Ruby code for quality: fat models & thin controllers, single responsibility, DRY, naming, Rails conventions, performance, and test coverage.
  Use whenever the user asks to review, audit, QA, or improve Rails code — models, controllers, services, jobs, concerns, migrations — or asks whether an implementation follows Rails best practices.
  Also trigger when the user mentions fat controllers, god models, SRP violations, business logic in the wrong layer, or wants a quality pass before merging.
---

# Rails Quality Review Skill

Apply the checks below in priority order. This is a review: prioritize not changing behaviour, and flag rather than rewrite unless asked to fix.

## 1. Fat models, thin controllers (primary focus)

A controller action does exactly four things: authorize, load, make one domain call, respond. Everything else is a finding. Hunt for:

- Business logic in actions or controller private methods: calculations, state decisions, record orchestration, conditionals on domain state (`if @order.paid? && @order.items.any? { ... }`).
- Multiple model writes composed in the controller — that's a domain operation; move it to a model method or PORO with a domain name, wrapped in a transaction.
- Params-shaping that encodes business rules (defaulting, deriving, or translating values before assignment) rather than plain strong-params filtering.
- Controllers reaching through associations to update other records the action isn't nominally about.
- A growing pile of controller private methods — each one is usually a domain concept looking for a home in a model, PORO, or form object.
- Callbacks (`before_action`) doing domain work rather than auth/loading.

The fix direction is always the same: name the operation in domain language and move it behind one method the controller calls (`@order.approve!`, `Estimate::Submission.new(...).save`).

## 2. Single responsibility

One reason to change per class and per method. Smells:

- Methods whose honest description needs "and" — validate *and* persist *and* notify. Split, or extract a PORO that coordinates the steps explicitly.
- Models that also format for display, build export payloads, call external APIs, or send notifications — presentation goes to helpers/presenters, integration to services/jobs.
- Service objects or jobs that both decide *and* do — separate the policy/decision from the side effect when both are non-trivial.
- Concerns used as junk drawers: a concern must model one capability (`Geocodable`), not "misc methods extracted to shorten the model".
- God models: when a model accumulates unrelated clusters of methods, propose extracting a cohesive PORO per cluster rather than living with it — but don't invent layers where the model is still coherent.

## 3. DRY

Avoid duplicated business rules, validations, scopes, queries, and view conditionals. Do not abstract merely because code looks similar — extract only when the duplication has the same reason to change.

## 4. Orthogonality & coupling

- Keep controllers, models, jobs, mailers, views, and service objects independent; changes in UI must not alter domain logic.
- Avoid long object chains, global state, excessive callbacks, and cross-model knowledge leaks. Prefer clear public methods that express domain intent.
- Keep business rules out of ERB, helpers, serializers, and presenters. Views ask meaningful questions (`order.refundable?`), they don't compute eligibility.

## 5. Broken windows

- Flag dead code, unclear names, ignored failing tests, skipped validations, TODOs without ownership, and inconsistent conventions.
- Flag every explanatory/narrative comment (doc blocks, inline "why" notes, comments restating the code) for removal — names and structure carry intent. Keep only functional pragmas (`# frozen_string_literal: true`, `# rubocop:...`, schema/codegen annotations, required license headers).
- Prefer small cleanup when touching nearby code.

## 6. Naming & domain language

- Names come from the business domain: `approve_invoice`, `capture_payment`, `schedule_inspection` — not `process`, `handle`, `perform_stuff`, `data`, `manager`, or generic `service`.
- Keep names concise and functional rather than technical, and consistent with existing patterns in the system.

## 7. Performance & algorithmic cost

- N+1 queries, unbounded `.all`, Ruby-side filtering of what the database should filter, missing indexes, unnecessary allocation, memory-heavy batch jobs.
- Prefer database filtering, pagination, batching, eager loading, and proper indexes.

## 8. Tests

- Changed behavior needs new or updated tests unless covered at a higher level: happy path, failure path, edge cases, authorization, validations, jobs, mailers.
- Bug fixes get a regression test.

## Rails-specific checks

- Follow Rails conventions before adding custom architecture; do not introduce architecture layers without clear pressure.
- Use service objects only when they clarify a real workflow.
- Prefer database constraints for real invariants: null constraints, foreign keys, unique indexes, check constraints.
- Wrap multi-write business operations in transactions.
- Avoid callbacks for surprising business workflows; avoid scopes with hidden side effects.
- Avoid broad `rescue StandardError`.
- Avoid `update_all`, `delete_all`, raw SQL, and callback-bypassing writes unless intentional.
- Prefer POROs for pure domain logic when Active Record would make the model incoherent.
- Keep migrations reversible and production-safe.
- Check authorization (policies) and parameter filtering in every controller action.
- Do not introduce gems when plain Rails/Ruby is enough.

## Output format

Return findings grouped and ordered:

1. Critical correctness issues
2. Layering violations (fat controllers, SRP, logic in the wrong layer)
3. Rails convention violations
4. Naming and readability issues
5. Maintainability issues
6. Performance/query issues
7. Test gaps
8. Suggested patch or refactor

For each finding give a `file:line` reference, the problem in one sentence, and the concrete fix — including where the code should live and what the domain-named method would be. Skip empty sections.
