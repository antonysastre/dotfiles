---
name: rails-erb-review
description: >
  Review Rails ERB view templates for clean code, reusability, organization, Rails conventions, HTML5 semantics, security, performance, mobile/PWA compatibility, and ui/ux best practices.
  Use this skill whenever a user asks to review, audit, check, or improve a Rails ERB file or template — including .html.erb, .json.erb, .js.erb, partials, layouts, and mailer views.
  Also trigger when the user pastes ERB code and asks for feedback, or when they mention issues like XSS, N+1 in views, logic in templates, missing escaping, or messy partials. This skill should be used proactively for any Rails view-related review task, even if the user just says "look at this ERB" or "what's wrong with this template".
---

# Rails ERB View Review Skill

You are reviewing a Rails ERB template. Work through the sections below in order — they are ranked by priority. Tailor depth to the complexity of the file: a 20-line partial needs less ceremony than a 200-line layout.

## 1. Clean code, reusability & organization (primary focus)

- **Repeated markup** — the same structure appearing twice or more belongs in a partial. Repeated `render` calls over a collection belong in collection rendering (`render partial: ..., collection:` or `render @records`).
- **Partial contracts** — partials take locals, never reach into instance variables. Recommend the strict-locals magic comment (`<%# locals: (record:, editable: false) %>`) so the contract is explicit and enforced.
- **No business logic in templates** — domain conditionals, calculations, and formatting rules move to helpers, presenters, or the model. The template should read as markup with data slotted in.
- **No query logic in templates** — flag any `.where`, `.order`, `.pluck`, `.count` on relations, or other query-building inside ERB; the controller or model should hand the view finished data.
- **Decomposition** — long templates (roughly 100+ lines, or several distinct page sections) should be split into named partials per section so each file has one job.
- **Collapse near-duplicate branches** — conditional branches that render the same markup differing only by a class, label, or attribute should compute the difference into a variable/helper and render once.

## 2. Rails conventions

- Route helpers over hardcoded paths (`project_path(@project)`, never `"/projects/#{@project.id}"`).
- Rails form and link helpers over raw markup: `form_with`, `button_to` (for non-GET actions), `link_to`, `image_tag`, field helpers.
- `t()` for every user-facing string; flag hardcoded copy in apps that use i18n.
- Tag helpers (`tag.div`, `class_names`/`token_list`) where they beat string interpolation for conditional classes and attributes.

## 3. HTML5 semantics & accessibility

- Semantic elements over div soup: `nav`, `main`, `header`, `footer`, `section`, `article`, `aside`, `figure` where the content warrants it.
- Correct heading hierarchy — one `h1` per page, no skipped levels; partials should fit the hierarchy of the pages that render them.
- `button` for actions, `a` for navigation — never a link with a click handler doing a mutation, never a div acting as a button.
- Every input has a bound `label` (or `aria-label` when a visible label is genuinely impossible).
- `ul`/`ol` for anything list-shaped; `table` only for tabular data.
- Valid nesting (no block elements inside `p`, no interactive elements inside interactive elements).
- Meaningful `alt` text on informative images, empty `alt=""` on decorative ones.
- ARIA only where native semantics can't do the job — flag redundant roles (`role="button"` on a `button`).

## 4. Security (ERB-specific checks only)

- `raw` or `html_safe` on anything user-influenced — this is the finding that matters most; trace where the value comes from.
- Rich text / user-authored HTML rendered without `sanitize`.
- Unescaped params or model attributes interpolated into HTML attributes, URLs, or inline JavaScript.
- `target="_blank"` without `rel="noopener"`.
- Forms built with raw `<form>` tags instead of Rails helpers (loses CSRF protection).

## 5. Performance

- N+1 queries triggered from the view: association access inside loops without preloading — name the association and suggest `includes`/`preload` at the call site in the controller.
- Heavy computation in the template (sorting, grouping, aggregating in ERB) — move it upstream.
- Obvious fragment-caching candidates: expensive, rarely-changing blocks keyed on a record (`cache record do ... end`).

## 6. Mobile compatibility

Every review must check that the template works on small touchscreens, not just desktop:

- **Responsive layout** — fixed pixel widths, wide tables, or multi-column grids without responsive breakpoints (e.g. Tailwind `sm:`/`md:`/`lg:` variants) that would overflow or cramp a ~375px viewport. Wide content (tables, code, long URLs) needs a horizontal-scroll wrapper (`overflow-x-auto`) rather than breaking the page layout.
- **Touch targets** — tap targets (links, buttons, icon-only actions) smaller than ~44×44px or packed too tightly to hit reliably with a finger. Hover-only affordances (`hover:` reveals, tooltips as the sole source of information, hover-triggered menus) with no touch equivalent.
- **Form inputs** — correct `type`/`inputmode`/`autocomplete` attributes so mobile keyboards match the field (`type="tel"`, `type="email"`, `inputmode="numeric"`, etc.). Font size on inputs below 16px triggers iOS Safari auto-zoom — flag it.
- **Viewport-relative sizing** — `100vh` heights that ignore mobile browser chrome (prefer `dvh`/`svh` or min-height), and fixed/sticky elements that can cover content or the on-screen keyboard.
- **Media** — images without `max-width: 100%`/responsive classes, missing `loading="lazy"` on below-the-fold images, heavy assets served unconditionally to mobile.

## 7. PWA compatibility

When the layout or template affects app-shell behavior, also check:

- **Offline/network resilience** — UI that fails silently without a connection (e.g. forms or Turbo actions with no error feedback); note when a degraded/offline state deserves handling.
- **Standalone display mode** — reliance on browser chrome (back button, URL bar) that disappears in `display: standalone`; in-app navigation must be self-sufficient (visible back links/breadcrumbs).
- **Safe areas** — fixed headers/footers/bottom bars without `env(safe-area-inset-*)` padding get clipped by notches and home indicators when installed to a home screen.
- **Head/meta in layouts** — when reviewing a layout: `viewport` meta (`width=device-width, initial-scale=1`, and `viewport-fit=cover` if safe-area insets are used), `theme-color`, manifest link, and apple touch icons present and consistent.
- **Touch behavior** — unintended double-tap zoom or scroll chaining on modals/drawers (`overscroll-behavior`), and tap-highlight artifacts on custom controls.

## Comments

Flag explanatory/narrative comments for removal — ERB comments (`<%# ... %>`) and HTML comments (`<!-- ... -->`) that merely describe what the markup does. Keep only functionally required comments: the strict-locals magic comment (`<%# locals: ... %>`), IE conditional comments, and templating/codegen markers. Markup should be self-explanatory through structure and partial names.

## Output format

Group findings by severity, most severe first:

- **Fix** — bugs, security issues, broken semantics, N+1s.
- **Consider** — reusability, organization, and convention improvements worth doing.
- **Nitpick** — minor polish; omit when there are many higher-severity findings.

For each finding give a `file:line` reference, a one-sentence statement of the problem, and a concrete rewrite in the project's existing idioms (e.g. Tailwind utilities, existing helpers and partials). End with a one-paragraph overall assessment. If a section above yields nothing, skip it — don't pad the review.
