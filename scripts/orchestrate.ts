#!/usr/bin/env bun
/**
 * MooriShell developer task orchestrator.
 * Keep task implementations in the existing project tools (PowerShell,
 * npm/Bun scripts, dotnet, git); this file only validates and dispatches.
 */
import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const args = process.argv.slice(2);
const task = args[0] ?? "help";

type Command = { exe: string; args: string[]; cwd?: string };

function run(command: Command): void {
  console.log(`\n> ${command.exe} ${command.args.join(" ")}`);
  const result = spawnSync(command.exe, command.args, {
    cwd: command.cwd ?? repoRoot,
    stdio: "inherit",
    shell: process.platform === "win32",
    env: process.env,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}

function powershell(script: string, scriptArgs: string[] = []): Command {
  return { exe: "pwsh", args: ["-NoLogo", "-NoProfile", "-NonInteractive", "-File", join(repoRoot, script), ...scriptArgs] };
}

function requirePath(path: string, description: string): string {
  const resolved = join(repoRoot, path);
  if (!existsSync(resolved)) throw new Error(`${description} not found: ${resolved}`);
  return resolved;
}

function printHelp(): void {
  console.log(`MooriShell developer orchestration (Bun + GNU Make)

Usage: make <target> [ARGS="..."]

Targets:
  help             Show this help
  doctor           Report toolchain prerequisites and repository state
  plan             Validate and print the offline provisioning plan
  test             Run M2 safety checks and Shelled UI tests
  test-safety      Run only offline M2 safety checks
  ui-focused       Run the Quick Settings UI regression test only
  build            Build Shelled .NET solution (no restore/network)
  styles           Compile Shelled UI styles
  worktree-list    List registered Git worktrees
  worktree-new     Create a worktree, e.g. make worktree-new ARGS="ui feature/shell-ui"
  worktree-remove  Remove a clean worktree, e.g. make worktree-remove ARGS="ui"

No target installs software, changes registry/shell settings, or deploys config.`);
}

function doctor(): void {
  console.log(`MooriShell root: ${repoRoot}`);
  for (const [tool, versionArgs] of [
    ["git", ["--version"]],
    ["bun", ["--version"]],
    ["make", ["--version"]],
    ["pwsh", ["--version"]],
    ["node", ["--version"]],
    ["npm", ["--version"]],
    ["dotnet", ["--version"]],
  ] as const) {
    const result = spawnSync(tool, versionArgs, { encoding: "utf8", shell: process.platform === "win32" });
    if (result.error || (result.status !== 0 && !result.stdout && !result.stderr)) {
      throw new Error(`Required tool unavailable: ${tool}`);
    }
    console.log(`${tool}: ${(result.stdout || result.stderr).trim().split(/\r?\n/)[0]}`);
  }
  run({ exe: "git", args: ["status", "--short", "--branch"] });
  run({ exe: "git", args: ["worktree", "list"] });
}

function worktreeAction(action: "New" | "Remove", values: string[]): void {
  if (values.length < 1) throw new Error(`${action} requires a worktree name.`);
  const worktreeName = values[0];
  const branch = values[1];
  const scriptArgs = [action, worktreeName];
  if (branch) scriptArgs.push("-Branch", branch);
  run(powershell("scripts/worktree.ps1", scriptArgs));
}

try {
  switch (task) {
    case "help":
      printHelp();
      break;
    case "doctor":
      doctor();
      break;
    case "plan":
      run(powershell("scripts/install.ps1", ["-Plan", "-Verbose"]));
      break;
    case "test": {
      run(powershell("scripts/test-install.ps1"));
      const ui = requirePath("src/shelled/src/Shell.UI.Web/package.json", "Shelled UI package");
      const nodeModules = join(dirname(ui), "node_modules");
      if (!existsSync(nodeModules)) throw new Error(`UI dependencies are not installed at ${nodeModules}; run the documented dependency setup when online.`);
      run({ exe: "bun", args: ["test"], cwd: dirname(ui) });
      break;
    }
    case "test-safety":
      run(powershell("scripts/test-install.ps1"));
      break;
    case "build": {
      const solution = requirePath("src/shelled/Shelled.sln", "Shelled solution");
      run({ exe: "dotnet", args: ["build", solution, "-c", "Release", "--no-restore"] });
      break;
    }
    case "styles": {
      const packageFile = requirePath("src/shelled/src/Shell.UI.Web/package.json", "Shelled UI package");
      const sass = join(dirname(packageFile), "node_modules", ".bin", "sass.cmd");
      if (!existsSync(sass)) throw new Error(`Sass is not installed at ${sass}; install UI dependencies first.`);
      run({ exe: sass, args: ["--no-source-map", "src/styles.scss", "src/styles.css"], cwd: dirname(packageFile) });
      break;
    }
    case "ui-focused": {
      const ui = requirePath("src/shelled/src/Shell.UI.Web/package.json", "Shelled UI package");
      const nodeModules = join(dirname(ui), "node_modules");
      if (!existsSync(nodeModules)) throw new Error(`UI dependencies are not installed at ${nodeModules}; run the documented dependency setup when online.`);
      run({ exe: "bun", args: ["test", "tests/e2e/quick-settings.e2e.test.js"], cwd: dirname(ui) });
      break;
    }
    case "worktree-list":
      run({ exe: "git", args: ["worktree", "list"] });
      break;
    case "worktree-new":
      worktreeAction("New", args.slice(1));
      break;
    case "worktree-remove":
      worktreeAction("Remove", args.slice(1));
      break;
    default:
      printHelp();
      throw new Error(`Unknown target: ${task}`);
  }
} catch (error) {
  console.error(`orchestrate: ${error instanceof Error ? error.message : String(error)}`);
  process.exit(1);
}
