SHELL := pwsh.exe
.SHELLFLAGS := -NoLogo -NoProfile -NonInteractive -Command

.PHONY: help doctor plan test test-safety ui-focused build styles worktree-list worktree-new worktree-remove

help:
	@bun run scripts/orchestrate.ts help

doctor:
	@bun run scripts/orchestrate.ts doctor

plan:
	@bun run scripts/orchestrate.ts plan

test:
	@bun run scripts/orchestrate.ts test

test-safety:
	@bun run scripts/orchestrate.ts test-safety

ui-focused:
	@bun run scripts/orchestrate.ts ui-focused

build:
	@bun run scripts/orchestrate.ts build

styles:
	@bun run scripts/orchestrate.ts styles

worktree-list:
	@bun run scripts/orchestrate.ts worktree-list

worktree-new:
	@bun run scripts/orchestrate.ts worktree-new $(ARGS)

worktree-remove:
	@bun run scripts/orchestrate.ts worktree-remove $(ARGS)
