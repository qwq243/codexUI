# Chinese UI Copy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace frontend-owned English UI copy with Simplified Chinese while keeping approved technical terms in English.

**Architecture:** Add a fixed Chinese copy module under `src/copy/` and route reusable static and dynamic UI text through it. Migrate user-facing strings in the main app shell, sidebar, content components, and frontend composables without introducing runtime locale switching or changing internal enum/storage values.

**Tech Stack:** Vue 3 SFCs, TypeScript, Vite, ripgrep, pnpm

---

## File Structure

### Create

- `src/copy/zhCN.ts`
- `docs/superpowers/plans/2026-04-13-chinese-ui-copy.md`

### Modify

- `src/App.vue`
- `src/components/sidebar/SidebarThreadControls.vue`
- `src/components/sidebar/SidebarThreadTree.vue`
- `src/components/layout/DesktopLayout.vue`
- `src/components/content/AccountMenu.vue`
- `src/components/content/ComposerDropdown.vue`
- `src/components/content/ComposerRuntimeDropdown.vue`
- `src/components/content/ComposerSearchDropdown.vue`
- `src/components/content/ComposerSkillPicker.vue`
- `src/components/content/QueuedMessages.vue`
- `src/components/content/RateLimitStatus.vue`
- `src/components/content/ReviewPane.vue`
- `src/components/content/SkillCard.vue`
- `src/components/content/SkillDetailModal.vue`
- `src/components/content/SkillsHub.vue`
- `src/components/content/ThreadComposer.vue`
- `src/components/content/ThreadConversation.vue`
- `src/components/content/ThreadMessageTypeMenu.vue`
- `src/components/content/ThreadPendingRequestPanel.vue`
- `src/composables/useDesktopState.ts`
- `src/composables/useDictation.ts`
- `src/composables/useGithubSkillsSync.ts`
- `tests.md`

### Responsibilities

- `src/copy/zhCN.ts`: centralized Simplified Chinese labels, helper text, placeholders, toasts, fallback errors, and dynamic copy helpers
- `src/App.vue`: top-level shell, settings, project opening flow, dropdown labels, new-thread and branch UI
- `src/components/sidebar/*`: sidebar headings, menus, dialogs, empty states, thread/project actions
- `src/components/content/*`: composer, queue, review, conversation, skills, approval UI, modal copy
- `src/composables/*`: frontend-owned visible fallback errors and toasts
- `tests.md`: manual validation steps for the Chinese UI pass

### Shared Rules

- Preserve `Codex`, `GitHub`, `OpenRouter`, model IDs, and `API key` in English.
- Translate frontend fallback text to Chinese.
- Do not rename underlying enum values like `steer`, `queue`, `approval`, `response`, or storage keys.

### Task 1: Create The Shared Chinese Copy Module

**Files:**
- Create: `src/copy/zhCN.ts`
- Modify: `src/App.vue`
- Test: shell grep check against `src/App.vue`

- [ ] **Step 1: Write the failing test**

Run:

```powershell
rg -n "Search threads|Filter threads|Skills Hub|Settings|Reload|Require ⌘ \+ enter to send|Appearance|Chat width" src/App.vue
```

Expected: matching English UI strings are reported from `src/App.vue`.

- [ ] **Step 2: Add the shared Chinese copy module**

Create `src/copy/zhCN.ts` with a focused exported object and helper functions like this:

```ts
export const zhCN = {
  common: {
    open: '打开',
    opening: '正在打开…',
    close: '关闭',
    cancel: '取消',
    save: '保存',
    delete: '删除',
    rename: '重命名',
    reload: '重新加载',
    search: '搜索',
    settings: '设置',
    loading: '加载中…',
    failed: '失败',
  },
  sidebar: {
    searchThreads: '搜索线程',
    filterThreads: '筛选线程…',
    clearSearch: '清除搜索',
    skillsHub: '技能中心',
    threads: '线程',
    noMatchingThreads: '没有匹配的线程',
    loadingThreads: '正在加载线程…',
  },
  settings: {
    title: '设置',
    accounts: '账号',
    expandAccounts: '展开账号',
    collapseAccounts: '收起账号',
    requireCommandEnter: '需要按 ⌘ + Enter 才发送',
    busySendAs: '忙碌时发送为',
    appearance: '外观',
    chatWidth: '聊天宽度',
  },
  actions: {
    sendAs(modeLabel: string) {
      return `发送为 ${modeLabel}`
    },
  },
} as const
```

- [ ] **Step 3: Wire the module into `src/App.vue`**

Add the import near the top of `src/App.vue`:

```ts
import { zhCN } from './copy/zhCN'
```

Replace the local help copy object shape so the values are Chinese-owned and reusable:

```ts
const SETTINGS_HELP = {
  sendWithEnter: '启用后按 Enter 发送；关闭后使用 Command+Enter 发送。',
  inProgressSendMode: '当当前轮次仍在运行时，选择新消息是接管当前轮次还是进入队列。',
  appearance: '在跟随系统、浅色和深色模式之间切换。',
  chatWidth: '选择桌面对话区域和输入框的最大宽度。',
  dictationClickToToggle: '使用点击开始、再次点击停止的听写方式，而不是按住说话。',
  dictationAutoSend: '停止录音后自动发送转写结果。',
  githubTrendingProjects: '显示或隐藏新建线程页面中的 GitHub 热门项目卡片。',
  dictationLanguage: '选择转写语言，或保持自动检测。',
} as const
```

- [ ] **Step 4: Run the targeted test to verify the module is ready to consume**

Run:

```powershell
rg -n "export const zhCN|actions:|settings:" src/copy/zhCN.ts
```

Expected: the new module exists and exposes grouped Chinese copy.

- [ ] **Step 5: Commit**

```bash
git add src/copy/zhCN.ts src/App.vue
git commit -m "feat: add shared Chinese UI copy module"
```

### Task 2: Translate The App Shell, Settings, And Project Opening Flow

**Files:**
- Modify: `src/App.vue`
- Test: shell grep check against `src/App.vue`

- [ ] **Step 1: Write the failing test**

Run:

```powershell
rg -n "Search threads|Filter threads|Skills Hub|Expand accounts|Collapse accounts|Reloading…|Reload|Require ⌘ \+ enter to send|When busy, send as|Appearance|Chat width|Click to toggle dictation|Auto send dictation|GitHub trending projects|Provider|Custom endpoint URL|Dictation language|Settings|Search branches|Choose folder|Open|Opening…|Folder name|Filter folders|Select branch|Review \(Open\)|Review|Search daily|Trending daily|New Project \(1\)|Auto-detect|Preferred:" src/App.vue
```

Expected: matching English strings are reported from `src/App.vue`.

- [ ] **Step 2: Replace the top-level template copy with `zhCN` values**

Update representative sections in `src/App.vue` like this:

```vue
<button
  class="sidebar-search-toggle"
  type="button"
  :aria-pressed="isSidebarSearchVisible"
  :aria-label="zhCN.sidebar.searchThreads"
  :title="zhCN.sidebar.searchThreads"
  @click="toggleSidebarSearch"
>
```

```vue
<input
  ref="sidebarSearchInputRef"
  v-model="sidebarSearchQuery"
  class="sidebar-search-input"
  type="text"
  :placeholder="zhCN.sidebar.filterThreads"
  @keydown="onSidebarSearchKeydown"
/>
```

```vue
<button
  v-if="sidebarSearchQuery.length > 0"
  class="sidebar-search-clear"
  type="button"
  :aria-label="zhCN.sidebar.clearSearch"
  @click="clearSidebarSearch"
>
```

Use the same pattern for the settings button text, settings rows, branch search placeholders, folder picker labels, open/create folder actions, review labels, and new-project defaults.

- [ ] **Step 3: Translate computed labels and fallback strings**

Replace inline English label data in script sections with Chinese display copy while keeping internal values unchanged:

```ts
const CHAT_WIDTH_PRESETS: Record<ChatWidthMode, ChatWidthPreset> = {
  standard: { label: '标准', columnMax: '45rem', cardMax: '76ch' },
  wide: { label: '宽', columnMax: '72rem', cardMax: '88ch' },
  'extra-wide': { label: '超宽', columnMax: '96rem', cardMax: '96ch' },
}
```

```ts
const githubTipsScopeOptions = computed<Array<{ value: GithubTipsScope; label: string }>>(() => [
  { value: 'search-daily', label: '搜索 - 今日' },
  { value: 'search-weekly', label: '搜索 - 本周' },
  { value: 'search-monthly', label: '搜索 - 本月' },
  { value: 'trending-daily', label: 'Trending - 今日' },
  { value: 'trending-weekly', label: 'Trending - 本周' },
  { value: 'trending-monthly', label: 'Trending - 本月' },
])
```

Update fallback messages such as:

```ts
const message = error instanceof Error ? error.message : '加载 Telegram 状态失败'
existingFolderError.value = '打开所选文件夹失败。'
createFolderError.value = '创建文件夹失败。'
defaultNewProjectName.value = '新项目 (1)'
```

- [ ] **Step 4: Run the targeted test to verify the main shell is translated**

Run:

```powershell
rg -n "Search threads|Filter threads|Skills Hub|Expand accounts|Collapse accounts|Reloading…|Reload|Require ⌘ \+ enter to send|When busy, send as|Appearance|Chat width|Click to toggle dictation|Auto send dictation|GitHub trending projects|Custom endpoint URL|Dictation language|Search branches|Choose folder|Opening…|Folder name|Filter folders|Select branch|Review \(Open\)|Review|New Project \(1\)|Auto-detect|Preferred:" src/App.vue
```

Expected: no matches, or only approved technical terms that are intentionally left in English.

- [ ] **Step 5: Commit**

```bash
git add src/App.vue
git commit -m "feat: translate app shell and settings to Chinese"
```

### Task 3: Translate Sidebar Navigation, Menus, And Dialogs

**Files:**
- Modify: `src/components/sidebar/SidebarThreadControls.vue`
- Modify: `src/components/sidebar/SidebarThreadTree.vue`
- Modify: `src/components/layout/DesktopLayout.vue`
- Test: shell grep check against sidebar files

- [ ] **Step 1: Write the failing test**

Run:

```powershell
rg -n "Threads|Organize threads|Organize|By project|Chronological list|No matching threads|Loading threads|Worktree thread|Edit name|Remove|Project name|No threads|Show less|Show more|Browse files|Export chat|Create chat fork|Rename thread|Delete thread|Thread title|Make it short and recognizable|Add title|Cancel|Save|Delete thread\\?|This will archive the thread|pin|thread_menu|project_menu|Awaiting approval|Awaiting response" src/components/sidebar/SidebarThreadTree.vue src/components/sidebar/SidebarThreadControls.vue src/components/layout/DesktopLayout.vue
```

Expected: matching English strings are reported from the sidebar files.

- [ ] **Step 2: Import and apply the Chinese copy in sidebar components**

Add the shared import where needed:

```ts
import { zhCN } from '../../copy/zhCN'
```

Replace template strings in `SidebarThreadTree.vue` like this:

```vue
<span class="thread-tree-header">{{ zhCN.sidebar.threads }}</span>
```

```vue
<p v-if="isSearchActive && filteredGroups.length === 0" class="thread-tree-no-results">
  {{ zhCN.sidebar.noMatchingThreads }}
</p>
```

```vue
<h3 class="rename-thread-title">重命名线程</h3>
<p class="rename-thread-subtitle">尽量简短且容易辨认。</p>
<input
  ref="renameThreadInputRef"
  v-model="renameThreadDraft"
  class="rename-thread-input"
  type="text"
  placeholder="输入标题…"
/>
```

- [ ] **Step 3: Translate sidebar script-driven labels and menu actions**

Update helper functions in `SidebarThreadTree.vue`:

```ts
function threadRequestLabel(thread: UiThread): string {
  return thread.pendingRequestState === 'approval' ? '等待批准' : '等待回复'
}
```

Translate menu items and dialog labels:

```vue
<button class="thread-menu-item" type="button" @click="onBrowseThreadFiles(openThreadMenuThread.id)">
  浏览文件
</button>
<button class="thread-menu-item" type="button" @click="onExportThread(openThreadMenuThread.id)">
  导出聊天
</button>
<button class="thread-menu-item" type="button" @click="onForkThread(openThreadMenuThread.id)">
  创建聊天分叉
</button>
```

Use Chinese display text for project organization options and show-more controls without changing behavior.

- [ ] **Step 4: Run the targeted test to verify the sidebar is translated**

Run:

```powershell
rg -n "Threads|Organize threads|Organize|By project|Chronological list|No matching threads|Loading threads|Worktree thread|Edit name|Remove|Project name|No threads|Show less|Show more|Browse files|Export chat|Create chat fork|Rename thread|Delete thread|Thread title|Make it short and recognizable|Add title|Cancel|Save|Delete thread\\?|This will archive the thread|Awaiting approval|Awaiting response" src/components/sidebar/SidebarThreadTree.vue src/components/sidebar/SidebarThreadControls.vue src/components/layout/DesktopLayout.vue
```

Expected: no matches remain for frontend-owned English UI copy.

- [ ] **Step 5: Commit**

```bash
git add src/components/sidebar/SidebarThreadControls.vue src/components/sidebar/SidebarThreadTree.vue src/components/layout/DesktopLayout.vue
git commit -m "feat: translate sidebar navigation and dialogs to Chinese"
```

### Task 4: Translate Composer, Conversation, Queue, And Approval Surfaces

**Files:**
- Modify: `src/components/content/ComposerDropdown.vue`
- Modify: `src/components/content/ComposerRuntimeDropdown.vue`
- Modify: `src/components/content/ComposerSearchDropdown.vue`
- Modify: `src/components/content/ComposerSkillPicker.vue`
- Modify: `src/components/content/QueuedMessages.vue`
- Modify: `src/components/content/ThreadComposer.vue`
- Modify: `src/components/content/ThreadConversation.vue`
- Modify: `src/components/content/ThreadMessageTypeMenu.vue`
- Modify: `src/components/content/ThreadPendingRequestPanel.vue`
- Modify: `src/composables/useDesktopState.ts`
- Modify: `src/composables/useDictation.ts`
- Test: shell grep check against composer/conversation files

- [ ] **Step 1: Write the failing test**

Run:

```powershell
rg -n "Browse files|Close review pane|Close|Remove |Add photos & files|Fast mode|Disable plan mode|Enable plan mode|Model|Skills|Search skills|Thinking|Saving thread before stop is available|Stop|Queue message|Send message|Send as |Send|Queue|None|Minimal|Low|Medium|High|Extra high|Open authorization link|Approval choices|No, and tell Codex what to do differently|Other answer|Yes|Yes for Session|Open link|Rollback to this response|Fork thread from this response|Response copied|Copy response|Jump to latest output|Close image preview|Close diff viewer|Failed|Deleted" src/components/content/ThreadComposer.vue src/components/content/ThreadConversation.vue src/components/content/ThreadPendingRequestPanel.vue src/components/content/QueuedMessages.vue src/composables/useDesktopState.ts src/composables/useDictation.ts
```

Expected: matching English UI strings are reported from the composer and conversation surface files.

- [ ] **Step 2: Translate template attributes, buttons, and dropdown labels**

Use `zhCN` imports and replace representative template strings like:

```vue
<button
  class="thread-composer-send"
  type="button"
  :aria-label="isTurnInProgress && activeInProgressMode === 'queue' ? '排队发送消息' : '发送消息'"
  :title="isTurnInProgress ? zhCN.actions.sendAs(activeInProgressMode === 'queue' ? '排队' : '接管') : '发送'"
>
```

```ts
const reasoningOptions: Array<{ value: ReasoningEffort; label: string }> = [
  { value: 'none', label: '无' },
  { value: 'minimal', label: '极少' },
  { value: 'low', label: '低' },
  { value: 'medium', label: '中' },
  { value: 'high', label: '高' },
  { value: 'xhigh', label: '极高' },
]
```

Translate dropdown placeholders such as `Model`, `Skills`, and `Thinking` to `模型`, `技能`, and `思考强度`.

- [ ] **Step 3: Translate dynamic status, queue, and approval copy**

Update message status and approval option copy in script sections:

```ts
function statusLabelForState(state: string, compact = false): string {
  switch (state) {
    case 'completed': return compact ? '完成' : '✓ 完成'
    case 'in_progress': return compact ? '进行中' : '… 进行中'
    case 'failed': return compact ? '失败' : '✗ 失败'
    default: return compact ? '等待中' : '○ 等待中'
  }
}
```

```ts
const quickApprovalOptions = [
  { id: 'accept', label: '是' },
  { id: 'acceptForSession', label: '本次会话始终允许' },
]
```

Translate frontend fallback errors in `useDesktopState.ts` and `useDictation.ts`, for example:

```ts
error.value = unknownError instanceof Error ? unknownError.message : '中断当前轮次失败'
error.value = unknownError instanceof Error ? unknownError.message : '回滚线程失败'
```

- [ ] **Step 4: Run the targeted test to verify the interaction surfaces are translated**

Run:

```powershell
rg -n "Browse files|Close review pane|Add photos & files|Fast mode|Disable plan mode|Enable plan mode|Model|Skills|Search skills|Thinking|Saving thread before stop is available|Stop|Queue message|Send message|Send as |Queue|None|Minimal|Low|Medium|High|Extra high|Open authorization link|Approval choices|No, and tell Codex what to do differently|Other answer|Yes|Yes for Session|Open link|Rollback to this response|Fork thread from this response|Response copied|Copy response|Jump to latest output|Close image preview|Close diff viewer|Failed|Deleted" src/components/content/ThreadComposer.vue src/components/content/ThreadConversation.vue src/components/content/ThreadPendingRequestPanel.vue src/components/content/QueuedMessages.vue src/composables/useDesktopState.ts src/composables/useDictation.ts
```

Expected: no matches remain for frontend-owned English UI copy.

- [ ] **Step 5: Commit**

```bash
git add src/components/content/ComposerDropdown.vue src/components/content/ComposerRuntimeDropdown.vue src/components/content/ComposerSearchDropdown.vue src/components/content/ComposerSkillPicker.vue src/components/content/QueuedMessages.vue src/components/content/ThreadComposer.vue src/components/content/ThreadConversation.vue src/components/content/ThreadMessageTypeMenu.vue src/components/content/ThreadPendingRequestPanel.vue src/composables/useDesktopState.ts src/composables/useDictation.ts
git commit -m "feat: translate chat interaction surfaces to Chinese"
```

### Task 5: Translate Review, Skills, And Account-Related Copy

**Files:**
- Modify: `src/components/content/AccountMenu.vue`
- Modify: `src/components/content/RateLimitStatus.vue`
- Modify: `src/components/content/ReviewPane.vue`
- Modify: `src/components/content/SkillCard.vue`
- Modify: `src/components/content/SkillDetailModal.vue`
- Modify: `src/components/content/SkillsHub.vue`
- Modify: `src/composables/useGithubSkillsSync.ts`
- Test: shell grep check against review/skills files

- [ ] **Step 1: Write the failing test**

Run:

```powershell
rg -n "Close review pane|Changes|Findings|Unstage all|Stage all|Revert all|Unstage file|Stage file|Revert file|Unstage hunk|Stage hunk|Revert hunk|Deleted|Renamed|Failed to load review snapshot|Failed to apply review action|Failed to initialize Git|Reviewing current changes|Reviewing against|Review in progress|Skills Hub|Browse and discover skills from the OpenClaw community|GitHub device login|Search skills|Search|Failed to load skills|skill installed|skill uninstalled|enabled|disabled|GitHub login successful|Failed GitHub login|Pulled skills from private sync repo|Pulled skills from upstream repo|Pushed skills to private sync repo|Startup sync completed|Logged out from GitHub" src/components/content/ReviewPane.vue src/components/content/SkillsHub.vue src/components/content/SkillCard.vue src/components/content/SkillDetailModal.vue src/components/content/AccountMenu.vue src/components/content/RateLimitStatus.vue src/composables/useGithubSkillsSync.ts
```

Expected: matching English strings are reported from the review, skills, and account files.

- [ ] **Step 2: Translate review pane labels and fallback errors**

Update review tab and action labels:

```ts
const tabs = [
  { value: 'changes' as const, label: '变更' },
  { value: 'findings' as const, label: '问题' },
]
```

```ts
function formatOperationLabel(operation: string): string {
  if (operation === 'delete') return '已删除'
  if (operation === 'rename') return '已重命名'
  return '已修改'
}
```

Translate frontend fallback errors:

```ts
snapshotError.value = error instanceof Error ? error.message : '加载评审快照失败'
reviewError.value = error instanceof Error ? error.message : '应用评审操作失败'
reviewStatusLabel.value = typeof item?.review === 'string' ? item.review : '评审进行中'
```

- [ ] **Step 3: Translate skills/account copy and toast helpers**

Apply Chinese copy in `SkillsHub.vue` and `useGithubSkillsSync.ts`:

```vue
<h2 class="skills-hub-title">技能中心</h2>
<p class="skills-hub-subtitle">浏览并发现来自 OpenClaw 社区的技能</p>
```

```ts
options.showToast('GitHub 登录成功')
options.showToast(syncStatus.value.loggedIn ? '已从私有同步仓库拉取技能' : '已从上游仓库拉取技能')
options.showToast('已将技能推送到私有同步仓库')
```

Keep `GitHub` and skill names in English where they are product identifiers, but translate the surrounding sentence structure.

- [ ] **Step 4: Run the targeted test to verify the review and skills surfaces are translated**

Run:

```powershell
rg -n "Close review pane|Changes|Findings|Unstage all|Stage all|Revert all|Unstage file|Stage file|Revert file|Unstage hunk|Stage hunk|Revert hunk|Deleted|Renamed|Failed to load review snapshot|Failed to apply review action|Failed to initialize Git|Reviewing current changes|Reviewing against|Review in progress|Skills Hub|Browse and discover skills from the OpenClaw community|GitHub device login|Search skills|Search|Failed to load skills|skill installed|skill uninstalled|enabled|disabled|GitHub login successful|Failed GitHub login|Pulled skills from private sync repo|Pulled skills from upstream repo|Pushed skills to private sync repo|Startup sync completed|Logged out from GitHub" src/components/content/ReviewPane.vue src/components/content/SkillsHub.vue src/components/content/SkillCard.vue src/components/content/SkillDetailModal.vue src/components/content/AccountMenu.vue src/components/content/RateLimitStatus.vue src/composables/useGithubSkillsSync.ts
```

Expected: no matches remain for frontend-owned English UI copy.

- [ ] **Step 5: Commit**

```bash
git add src/components/content/AccountMenu.vue src/components/content/RateLimitStatus.vue src/components/content/ReviewPane.vue src/components/content/SkillCard.vue src/components/content/SkillDetailModal.vue src/components/content/SkillsHub.vue src/composables/useGithubSkillsSync.ts
git commit -m "feat: translate review and skills surfaces to Chinese"
```

### Task 6: Sweep For Residual English, Update Tests, And Build

**Files:**
- Modify: `tests.md`
- Test: global shell grep check and project build

- [ ] **Step 1: Write the failing test**

Run:

```powershell
rg -n "Search threads|Filter threads|Skills Hub|Settings|Reload|Open|Close|Delete|Rename|Review|Queue|Send|Search skills|Loading|No threads|No matching threads|Browse files|Export chat|Create chat fork|Open link|Jump to latest|Failed to|Logged out from GitHub|GitHub login successful" src/App.vue src/components src/composables
```

Expected: any remaining frontend-owned English UI strings are listed so they can be triaged and either translated or explicitly accepted as technical terms.

- [ ] **Step 2: Resolve remaining frontend-owned English copy**

Apply final cleanup edits for any leftover matches discovered in Step 1. Do not translate approved technical terms such as `Codex`, `GitHub`, `OpenRouter`, model IDs, or `API key`.

Representative target state:

```ts
const visibleEnglishExceptions = ['Codex', 'GitHub', 'OpenRouter', 'API key']
```

Use that rule while cleaning the remaining matches rather than changing any protocol or brand identifiers.

- [ ] **Step 3: Update manual verification documentation**

Append a new section to `tests.md` with this structure:

```md
## Chinese UI Copy

### Prerequisites / Setup
- Run `pnpm install`
- Start the app with `pnpm run dev`

### Steps
1. Open the app and verify the sidebar search, settings, and project-opening UI are in Chinese.
2. Open a thread and verify composer controls, queue actions, approval UI, and conversation actions are in Chinese.
3. Open Review and Skills Hub and verify tabs, actions, toasts, and fallback empty-state text are in Chinese.

### Expected Results
- Frontend-owned UI copy is shown in Simplified Chinese.
- `Codex`, `GitHub`, `OpenRouter`, model IDs, and `API key` remain in English where applicable.

### Rollback / Cleanup
- Revert the branch commits for the Chinese copy pass if the terminology needs to be revised.
```

- [ ] **Step 4: Run final verification**

Run:

```powershell
pnpm run build
```

Expected: Vite and `vue-tsc` complete successfully without new type or build errors.

Then run:

```powershell
rg -n "Search threads|Filter threads|Skills Hub|Settings|Reload|Delete thread|Rename thread|Open link|Jump to latest output|Failed to load skills|GitHub login successful" src/App.vue src/components src/composables
```

Expected: no matches for frontend-owned English UI copy.

- [ ] **Step 5: Commit**

```bash
git add tests.md src/App.vue src/components src/composables src/copy/zhCN.ts
git commit -m "docs: add Chinese UI verification steps"
```

## Self-Review

- Spec coverage: tasks cover shared copy organization, top-level shell, sidebar, interaction surfaces, review/skills surfaces, fallback messages, and `tests.md` updates.
- Placeholder scan: no `TODO`, `TBD`, or deferred implementation markers remain.
- Type consistency: all tasks rely on a single `zhCN` module, preserve existing internal enum values, and only translate display text.
