/// Styles of the web test menu, injected in the page by the presenter so that
/// it also works when `packages/` is not served (wasm or `dart compile js`).
library;

const _darkTokens = '''
  color-scheme: dark;
  --tm-bg: #0b0f14;
  --tm-dot: rgba(255, 255, 255, 0.07);
  --tm-surface: #0f141a;
  --tm-surface-2: #141a22;
  --tm-surface-3: #1b232e;
  --tm-border: #27303c;
  --tm-text: #d7dee7;
  --tm-muted: #8b96a5;
  --tm-faint: #5d6776;
  --tm-accent: #22c1dc;
  --tm-on-accent: #041a1f;
  --tm-green: #3fca7a;
  --tm-red: #f47067;
  --tm-amber: #e3b341;
  --tm-purple: #b392f0;
  --tm-shadow: 0 24px 60px -24px rgba(0, 0, 0, 0.7);
''';

const _lightTokens = '''
  color-scheme: light;
  --tm-bg: #eef1f5;
  --tm-dot: rgba(15, 23, 42, 0.09);
  --tm-surface: #ffffff;
  --tm-surface-2: #f6f8fa;
  --tm-surface-3: #eaeef2;
  --tm-border: #d0d7de;
  --tm-text: #1f2328;
  --tm-muted: #59636e;
  --tm-faint: #8c959f;
  --tm-accent: #0a7ea4;
  --tm-on-accent: #ffffff;
  --tm-green: #1a7f37;
  --tm-red: #cf222e;
  --tm-amber: #9a6700;
  --tm-purple: #8250df;
  --tm-shadow: 0 24px 60px -28px rgba(15, 23, 42, 0.35);
''';

/// The test menu web stylesheet, every rule is scoped under `.tm-root`.
const testMenuWebCss =
    '''
body.tm-page {
  margin: 0;
}
.tm-root {
$_darkTokens
  --tm-font: ui-monospace, "JetBrains Mono", "Cascadia Mono", "SF Mono", Menlo,
    Consolas, "DejaVu Sans Mono", "Liberation Mono", "Courier New", monospace;
  --tm-pad: 24px;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
  min-height: 100vh;
  min-height: 100dvh;
  padding: var(--tm-pad) 16px;
  background-color: var(--tm-bg);
  background-image: radial-gradient(var(--tm-dot) 1px, transparent 1px);
  background-size: 16px 16px;
  color: var(--tm-text);
  font: 13.5px/1.55 var(--tm-font);
  -webkit-text-size-adjust: 100%;
}
@media (prefers-color-scheme: light) {
  .tm-root:not([data-theme="dark"]) {
$_lightTokens
  }
}
.tm-root[data-theme="light"] {
$_lightTokens
}
.tm-root *,
.tm-root *::before,
.tm-root *::after {
  box-sizing: inherit;
}
/* zero specificity reset so that component rules below win */
.tm-root :where(button) {
  font: inherit;
  color: inherit;
}
.tm-root svg {
  width: 16px;
  height: 16px;
  fill: none;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}
.tm-root :focus-visible {
  outline: 2px solid var(--tm-accent);
  outline-offset: 1px;
}

/* window */
.tm-window {
  display: flex;
  flex-direction: column;
  width: 100%;
  max-width: 1180px;
  height: calc(100vh - 2 * var(--tm-pad));
  height: calc(100dvh - 2 * var(--tm-pad));
  min-height: 420px;
  overflow: hidden;
  background: var(--tm-surface);
  border: 1px solid var(--tm-border);
  border-radius: 12px;
  box-shadow: var(--tm-shadow);
}

/* title bar */
.tm-titlebar {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 10px 9px 14px;
  background: var(--tm-surface-2);
  border-bottom: 1px solid var(--tm-border);
}
.tm-dots {
  display: flex;
  flex: none;
  gap: 6px;
}
.tm-dots span {
  width: 11px;
  height: 11px;
  border-radius: 50%;
  background: #ff5f57;
}
.tm-dots span:nth-child(2) {
  background: #febc2e;
}
.tm-dots span:nth-child(3) {
  background: #28c840;
}
.tm-title {
  min-width: 0;
  overflow: hidden;
  font-weight: 700;
  white-space: nowrap;
  text-overflow: ellipsis;
}
.tm-status {
  --tm-status: var(--tm-green);
  display: inline-flex;
  flex: none;
  align-items: center;
  gap: 6px;
  padding: 1px 8px;
  border: 1px solid color-mix(in srgb, var(--tm-status) 45%, transparent);
  border-radius: 999px;
  background: color-mix(in srgb, var(--tm-status) 12%, transparent);
  color: var(--tm-status);
  font-size: 10.5px;
  font-weight: 700;
  letter-spacing: 0.08em;
}
.tm-status::before {
  content: "";
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
}
.tm-status[data-state="running"] {
  --tm-status: var(--tm-amber);
}
.tm-status[data-state="input"] {
  --tm-status: var(--tm-accent);
}
.tm-status[data-state="error"] {
  --tm-status: var(--tm-red);
}
.tm-status[data-state="running"]::before,
.tm-status[data-state="input"]::before {
  animation: tm-pulse 1.1s ease-in-out infinite;
}
@keyframes tm-pulse {
  50% {
    opacity: 0.2;
  }
}
.tm-spacer {
  flex: 1;
}
.tm-icon-btn {
  display: inline-grid;
  flex: none;
  place-items: center;
  width: 30px;
  height: 30px;
  padding: 0;
  border: 1px solid transparent;
  border-radius: 7px;
  background: transparent;
  color: var(--tm-muted);
  cursor: pointer;
}
.tm-icon-btn:hover {
  border-color: var(--tm-border);
  background: var(--tm-surface-3);
  color: var(--tm-text);
}

/* breadcrumb */
.tm-crumbs {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border-bottom: 1px solid var(--tm-border);
  font-size: 12.5px;
}
.tm-crumb-path {
  display: flex;
  flex: 1;
  flex-wrap: wrap;
  align-items: center;
  gap: 2px 6px;
  min-width: 0;
}
.tm-sep {
  color: var(--tm-accent);
  font-weight: 700;
}
.tm-crumb {
  padding: 0 2px;
  border: 0;
  border-radius: 4px;
  background: none;
  font-weight: 700;
  cursor: pointer;
}
.tm-crumb:hover {
  color: var(--tm-accent);
  text-decoration: underline;
}
.tm-crumb[aria-current] {
  color: var(--tm-green);
  text-decoration: none;
  cursor: default;
}
.tm-crumb-meta {
  flex: none;
  color: var(--tm-faint);
  font-size: 11.5px;
}

/* recent items */
.tm-quick {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  overflow-x: auto;
  border-bottom: 1px solid var(--tm-border);
  scrollbar-width: none;
}
.tm-quick[hidden] {
  display: none;
}
.tm-quick-label {
  flex: none;
  margin-right: 2px;
  color: var(--tm-faint);
  font-size: 10.5px;
  font-weight: 700;
  letter-spacing: 0.08em;
}
.tm-chip {
  flex: none;
  max-width: 24ch;
  overflow: hidden;
  padding: 2px 8px;
  border: 1px solid var(--tm-border);
  border-radius: 5px;
  background: var(--tm-surface-3);
  font-size: 12px;
  white-space: nowrap;
  text-overflow: ellipsis;
  cursor: pointer;
}
.tm-chip:hover {
  border-color: var(--tm-accent);
  color: var(--tm-accent);
}
.tm-chip-key {
  color: var(--tm-accent);
  font-weight: 700;
}

/* main area: stacked on small screens, menu sidebar on large ones */
.tm-main {
  display: flex;
  flex: 1;
  flex-direction: column;
  min-height: 0;
  overflow: auto;
}
.tm-output {
  padding: 12px 14px 4px;
}
.tm-menu {
  padding: 10px 14px 14px;
}
@media (min-width: 900px) {
  .tm-main {
    display: grid;
    grid-template-columns: minmax(260px, 340px) minmax(0, 1fr);
    overflow: hidden;
  }
  .tm-menu {
    order: -1;
    overflow: auto;
    padding: 14px 12px;
    border-right: 1px solid var(--tm-border);
  }
  .tm-output {
    overflow: auto;
    padding: 14px 18px;
  }
}

/* output */
.tm-log {
  display: flex;
  flex-direction: column;
  gap: 2px;
  margin: 0;
}
.tm-log:empty::before {
  content: "Output appears here. Pick an item, or type its number below.";
  color: var(--tm-faint);
  font-style: italic;
}
.tm-line {
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}
.tm-line-cmd {
  margin-top: 10px;
  color: var(--tm-muted);
}
.tm-line-cmd:first-child {
  margin-top: 0;
}
.tm-line-cmd::before {
  content: "\\276F  ";
  color: var(--tm-accent);
}
.tm-line-info {
  color: var(--tm-muted);
}
.tm-line-error {
  padding: 3px 0 3px 10px;
  border-left: 2px solid var(--tm-red);
  background: color-mix(in srgb, var(--tm-red) 8%, transparent);
  color: var(--tm-red);
}
.tm-line-error summary {
  color: var(--tm-muted);
  font-size: 12px;
  cursor: pointer;
}
.tm-line-error pre {
  margin: 4px 0 0;
  color: var(--tm-muted);
  font: inherit;
  font-size: 12px;
  white-space: pre-wrap;
}
.tm-line-prompt {
  margin: 6px 0;
  padding: 8px 10px;
  border: 1px solid var(--tm-border);
  border-radius: 7px;
  background: var(--tm-surface-2);
}
.tm-line-prompt[data-waiting] {
  border-color: var(--tm-amber);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--tm-amber) 16%, transparent);
}
.tm-prompt-label {
  color: var(--tm-amber);
  font-weight: 700;
}
.tm-prompt-answer {
  display: block;
  color: var(--tm-green);
}
.tm-prompt-answer::before {
  content: "\\21B3  ";
  color: var(--tm-faint);
}

/* menu */
.tm-menu-title {
  display: flex;
  flex-wrap: wrap;
  gap: 0 6px;
  margin: 0 0 8px;
  font-size: 15px;
  font-weight: 700;
}
.tm-menu-title [aria-current] {
  color: var(--tm-green);
}
.tm-menu-list {
  display: flex;
  flex-direction: column;
  gap: 1px;
  margin: 0;
  padding: 0;
  list-style: none;
}
.tm-item {
  display: flex;
  align-items: baseline;
  gap: 10px;
  width: 100%;
  padding: 5px 8px;
  border: 0;
  border-radius: 6px;
  background: transparent;
  text-align: left;
  cursor: pointer;
}
.tm-item:hover {
  background: var(--tm-surface-3);
}
.tm-item-key {
  flex: none;
  min-width: 2ch;
  color: var(--tm-accent);
  font-weight: 700;
  text-align: right;
}
.tm-item-name {
  flex: 1;
  min-width: 0;
  overflow-wrap: anywhere;
}
.tm-item-tag {
  flex: none;
  padding: 0 5px;
  border: 1px solid var(--tm-border);
  border-radius: 4px;
  color: var(--tm-faint);
  font-size: 10px;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}
.tm-item-menu .tm-item-name {
  color: var(--tm-purple);
}
.tm-item-menu .tm-item-name::after {
  content: " \\203A";
  color: var(--tm-faint);
}
.tm-item-exit .tm-item-key,
.tm-item-exit .tm-item-name {
  color: var(--tm-red);
}
.tm-item[data-running] {
  background: color-mix(in srgb, var(--tm-amber) 12%, transparent);
}
.tm-item[data-running] .tm-item-key {
  color: var(--tm-amber);
}

/* footer: keypad and command line */
.tm-footer {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 8px 12px 12px;
  border-top: 1px solid var(--tm-border);
  background: var(--tm-surface-2);
}
.tm-keys {
  display: flex;
  align-items: center;
  gap: 6px;
}
.tm-keys-items {
  display: flex;
  flex: 1;
  gap: 6px;
  min-width: 0;
  margin-right: 6px;
  padding-bottom: 1px;
  overflow-x: auto;
  scrollbar-width: none;
}
.tm-key {
  display: inline-grid;
  flex: none;
  place-items: center;
  min-width: 30px;
  height: 28px;
  padding: 0 8px;
  border: 1px solid var(--tm-border);
  border-bottom-width: 2px;
  border-radius: 6px;
  background: var(--tm-surface-3);
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
}
.tm-key:hover {
  border-color: var(--tm-accent);
}
.tm-key:active {
  transform: translateY(1px);
}
.tm-key:disabled {
  opacity: 0.4;
  cursor: default;
  transform: none;
}
.tm-key-exit {
  color: var(--tm-red);
}
.tm-command {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0;
}
.tm-command-caret {
  flex: none;
  color: var(--tm-accent);
  font-weight: 700;
}
.tm-input {
  flex: 1;
  min-width: 0;
  padding: 8px 12px;
  border: 1px solid var(--tm-border);
  border-radius: 8px;
  outline: none;
  background: var(--tm-surface);
  color: var(--tm-text);
  font: inherit;
  font-size: 14px;
}
.tm-input::placeholder {
  color: var(--tm-faint);
}
.tm-input:focus {
  border-color: var(--tm-accent);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--tm-accent) 18%, transparent);
}
.tm-root[data-prompting] .tm-input {
  border-color: var(--tm-amber);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--tm-amber) 18%, transparent);
}
.tm-root[data-prompting] .tm-command-caret {
  color: var(--tm-amber);
}
.tm-send {
  display: inline-grid;
  flex: none;
  place-items: center;
  width: 40px;
  height: 36px;
  padding: 0;
  border: 0;
  border-radius: 8px;
  background: var(--tm-accent);
  color: var(--tm-on-accent);
  cursor: pointer;
}
.tm-send:hover {
  filter: brightness(1.12);
}

/* phones: full bleed window */
@media (max-width: 560px) {
  .tm-root {
    --tm-pad: 0px;
    padding: 0;
  }
  .tm-window {
    min-height: 0;
    border: 0;
    border-radius: 0;
  }
  .tm-input {
    font-size: 16px;
  }
}
@media (prefers-reduced-motion: reduce) {
  .tm-status::before {
    animation: none !important;
  }
}
''';
