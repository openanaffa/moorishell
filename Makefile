SHELL := pwsh.exe
.SHELLFLAGS := -NoLogo -NoProfile -NonInteractive -Command

.PHONY: help doctor plan test test-safety ui-focused restore ui-install build styles worktree-list worktree-new worktree-remove

help:
	@bun run help

doctor:
	@bun run doctor

plan:
	@bun run plan

test:
	@bun run test

test-safety:
	@bun run test:safety

ui-focused:
	@bun run test:ui

build:
	@bun run build

# Explicit dependency restore: may use network/NuGet sources.
restore:
	@bun run restore

# Explicit UI dependency install: may use network; frozen lockfile required.
ui-install:
	@bun run ui:install

styles:
	@bun run styles

worktree-list:
	@bun run worktree:list

worktree-new:
	@bun run worktree:new -- $(ARGS)

worktree-remove:
	@bun run worktree:remove -- $(ARGS)
