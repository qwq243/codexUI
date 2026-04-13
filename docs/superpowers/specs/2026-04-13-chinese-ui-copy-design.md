# Chinese UI Copy Design

## Summary

Translate the user-facing interface of the application from English to Simplified Chinese while keeping technical brand terms in English. The application will remain single-language and will not add runtime language switching or a full i18n framework.

## Goals

- Make the interface readable for Chinese-speaking users.
- Translate user-facing labels, buttons, placeholders, helper text, empty states, fallback error copy, toast messages, and accessibility copy such as `title` and `aria-label`.
- Keep technical brand terms in English, including `Codex`, `GitHub`, `OpenRouter`, model names, and `API key`.
- Keep implementation lightweight and maintainable.

## Non-Goals

- Do not introduce full i18n or locale switching.
- Do not translate code comments, variable names, API fields, or internal identifiers.
- Do not rewrite backend-provided raw error text that is not owned by the frontend.
- Do not change protocol enums or storage keys just to make them Chinese.

## Scope

The change covers frontend-owned user-visible copy in:

- `src/App.vue`
- `src/components/content/**`
- `src/components/sidebar/**`
- frontend composables that emit visible status or toast text, such as `src/composables/useGithubSkillsSync.ts`

The change includes:

- main navigation and sidebar copy
- settings panel copy
- new project / open folder flows
- conversation composer copy
- queued message controls
- approval and pending request UI
- review pane copy
- Skills Hub and skill detail copy
- fallback status and error messages defined in the frontend

## Recommended Approach

Use a fixed Simplified Chinese copy module instead of a full i18n system.

### Option A: Inline replacement only

Replace English strings in each component directly.

Pros:

- fastest to start

Cons:

- strings stay fragmented
- easier to miss dynamic messages
- harder to maintain after this pass

### Option B: Fixed Chinese copy module

Create a frontend copy module for reusable static and dynamic Chinese text, then migrate components to it.

Pros:

- keeps copy more centralized
- reduces missed strings
- supports dynamic text generators cleanly
- avoids overengineering

Cons:

- slightly more setup than direct replacement

### Option C: Full i18n

Add a locale framework and translation plumbing.

Pros:

- scalable for multilingual support

Cons:

- unnecessary for a fixed Chinese UI request
- higher implementation and maintenance cost

### Decision

Choose Option B.

## Design

### Copy Organization

Add a dedicated Chinese copy module under `src/`, for example `src/copy/zhCN.ts`.

This module should contain:

- static labels and headings
- placeholders and helper text
- button text
- empty-state and fallback messages
- dynamic copy helpers for text that includes variables

Dynamic helpers should cover cases like:

- open / opening states
- review status text
- install or uninstall skill messages
- branch-related labels
- action-specific fallback errors

### Translation Boundaries

Translate text when it is defined by the frontend and visible to users.

Keep English for:

- brand and platform names such as `Codex`, `GitHub`, `OpenRouter`
- model identifiers
- `API key`
- backend-returned raw error payloads when the frontend is only displaying them

When a frontend fallback wraps an error, the fallback itself should be Chinese.

### Component Migration Strategy

Migrate high-impact surfaces first, then the supporting UI:

1. `src/App.vue`
2. `src/components/content/*`
3. `src/components/sidebar/*`
4. frontend composables with user-facing messages

Within each file, replace:

- visible template text
- `placeholder`
- `title`
- `aria-label`
- computed labels and option lists
- fallback error messages
- toast text

Do not rename internal state such as enum values like `steer` or `queue` unless the value itself is shown to users. In those cases, map the display text to Chinese without changing the underlying value.

## Validation Plan

Validation is code-level and build-level.

1. Search the frontend source for obvious English UI strings before editing to establish a working checklist.
2. Implement the Chinese copy pass.
3. Search again for remaining obvious user-visible English strings and resolve any misses that are frontend-owned.
4. Run the frontend build and type check through the existing build script.
5. Update `tests.md` with a manual verification section for the Chinese UI copy pass.

Playwright is not required unless explicitly requested by the user.

CJS smoke testing is not required because this task does not change package loading or public module entry behavior.

## Risks And Mitigations

### Risk: missed strings in scattered components

Mitigation:

- use a centralized copy module
- perform before/after grep checks

### Risk: translating technical terms users recognize in English

Mitigation:

- preserve approved English technical names
- translate surrounding explanatory text only

### Risk: changing internal behavior while replacing display labels

Mitigation:

- translate display text only
- keep enum values, storage keys, and backend payload formats unchanged

## Acceptance Criteria

- The app UI is predominantly Simplified Chinese for frontend-owned text.
- Approved English technical terms remain in English.
- No full i18n framework or language toggle is added.
- The project builds successfully after the copy changes.
- `tests.md` includes manual verification steps for the Chinese UI pass.
