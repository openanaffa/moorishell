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
const shelledSource = resolve(
	process.env.SHELLED_SOURCE || join(repoRoot, "src", "shelled"),
);

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
	return {
		exe: "pwsh",
		args: [
			"-NoLogo",
			"-NoProfile",
			"-NonInteractive",
			"-File",
			join(repoRoot, script),
			...scriptArgs,
		],
	};
}

export function requirePath(path: string, description: string): string {
	const resolved = join(repoRoot, path);
	if (!existsSync(resolved))
		throw new Error(`${description} not found: ${resolved}`);
	return resolved;
}

function requireShelledPath(relativePath: string, description: string): string {
	const path = join(shelledSource, relativePath);
	if (!existsSync(path)) {
		const overrideHint = process.env.SHELLED_SOURCE
			? `Check SHELLED_SOURCE=${shelledSource}.`
			: "Initialize the Shelled submodule or set SHELLED_SOURCE to a full local Shelled checkout.";
		throw new Error(`${description} not found: ${path}. ${overrideHint}`);
	}
	return path;
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
  restore          Restore Shelled NuGet assets (may use network)
  ui-install       Install UI dependencies from the frozen lockfile (may use network)
  build            Build Shelled .NET solution offline (requires restore assets)
  styles           Compile Shelled UI styles
  worktree-list    List registered Git worktrees
  worktree-new     Create a worktree, e.g. make worktree-new ARGS="ui feature/shell-ui"
  worktree-remove  Remove a clean worktree, e.g. make worktree-remove ARGS="ui"

No target installs software, changes registry/shell settings, or deploys config.`);
	console.log(`\nShelled source: ${shelledSource}`);
}

function doctor(): void {
	console.log(`MooriShell root: ${repoRoot}`);
	console.log(`Shelled source: ${shelledSource}`);
	for (const [tool, versionArgs] of [
		["git", ["--version"]],
		["bun", ["--version"]],
		["make", ["--version"]],
		["pwsh", ["--version"]],
		["node", ["--version"]],
		["npm", ["--version"]],
		["dotnet", ["--version"]],
	] as const) {
		const result = spawnSync(tool, versionArgs, {
			encoding: "utf8",
			shell: process.platform === "win32",
		});
		if (
			result.error ||
			(result.status !== 0 && !result.stdout && !result.stderr)
		) {
			throw new Error(`Required tool unavailable: ${tool}`);
		}
		console.log(
			`${tool}: ${(result.stdout || result.stderr).trim().split(/\r?\n/)[0]}`,
		);
	}
	run({ exe: "git", args: ["status", "--short", "--branch"] });
	run({ exe: "git", args: ["worktree", "list"] });

	const solution = join(shelledSource, "Shelled.sln");
	const uiPackage = join(shelledSource, "src", "Shell.UI.Web", "package.json");
	const uiModules = join(shelledSource, "src", "Shell.UI.Web", "node_modules");
	console.log("\nDependency readiness:");
	if (existsSync(solution)) {
		const projects = spawnSync("dotnet", ["sln", solution, "list"], {
			encoding: "utf8",
			shell: true,
		});
		const projectPaths = (projects.stdout ?? "")
			.split(/\r?\n/)
			.filter((line) => /\.(csproj|fsproj|vbproj)$/i.test(line.trim()));
		let missingAssets = 0;
		for (const project of projectPaths) {
			const projectFile = join(dirname(solution), project.trim());
			if (!existsSync(join(dirname(projectFile), "obj", "project.assets.json")))
				missingAssets += 1;
		}
		console.log(
			`Shelled NuGet assets: ${missingAssets === 0 ? "ready" : `missing for ${missingAssets}/${projectPaths.length} projects (run make restore)`}`,
		);
	} else {
		console.log(
			"Shelled solution: missing (initialize the src/shelled submodule)",
		);
	}
	if (!existsSync(uiPackage))
		console.log(
			"Shelled UI package: unavailable (initialize the src/shelled submodule)",
		);
	else if (!existsSync(uiModules))
		console.log(
			"Shelled UI dependencies: missing (run make ui-install when online)",
		);
	else console.log("Shelled UI dependencies: present");
}

function worktreeAction(action: "New" | "Remove", values: string[]): void {
	const worktreeName = values[0];
	if (!worktreeName) throw new Error(`${action} requires a worktree name.`);
	const branch = values[1];
	const scriptArgs = [action, worktreeName];
	if (branch !== undefined) scriptArgs.push("-Branch", branch);
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
			const ui = requireShelledPath(
				join("src", "Shell.UI.Web", "package.json"),
				"Shelled UI package",
			);
			const nodeModules = join(dirname(ui), "node_modules");
			if (!existsSync(nodeModules))
				throw new Error(
					`UI dependencies are not installed at ${nodeModules}; run the documented dependency setup when online.`,
				);
			run({ exe: "bun", args: ["test"], cwd: dirname(ui) });
			break;
		}
		case "test-safety":
			run(powershell("scripts/test-install.ps1"));
			break;
		case "build": {
			const solution = requireShelledPath("Shelled.sln", "Shelled solution");
			run({
				exe: "dotnet",
				args: ["build", solution, "-c", "Release", "--no-restore"],
			});
			break;
		}
		case "restore": {
			const solution = requireShelledPath("Shelled.sln", "Shelled solution");
			run({ exe: "dotnet", args: ["restore", solution] });
			break;
		}
		case "styles": {
			const packageFile = requireShelledPath(
				join("src", "Shell.UI.Web", "package.json"),
				"Shelled UI package",
			);
			const uiRoot = dirname(packageFile);
			const sassCandidates = [
				join(uiRoot, "node_modules", ".bin", "sass.cmd"),
				join(uiRoot, "node_modules", ".bin", "sass.exe"),
				join(uiRoot, "node_modules", "sass", "sass.js"),
			];
			const sass = sassCandidates.find(existsSync);
			if (!sass)
				throw new Error(
					`Sass is not installed under ${uiRoot}; run make ui-install when online.`,
				);
			if (sass.endsWith("sass.js")) {
				run({
					exe: "bun",
					args: [sass, "--no-source-map", "src/styles.scss", "src/styles.css"],
					cwd: uiRoot,
				});
				break;
			}
			run({
				exe: sass,
				args: ["--no-source-map", "src/styles.scss", "src/styles.css"],
				cwd: uiRoot,
			});
			break;
		}
		case "ui-install": {
			const ui = requireShelledPath(
				join("src", "Shell.UI.Web", "package.json"),
				"Shelled UI package",
			);
			run({
				exe: "bun",
				args: ["install", "--frozen-lockfile"],
				cwd: dirname(ui),
			});
			break;
		}
		case "ui-focused": {
			const ui = requireShelledPath(
				join("src", "Shell.UI.Web", "package.json"),
				"Shelled UI package",
			);
			const nodeModules = join(dirname(ui), "node_modules");
			if (!existsSync(nodeModules))
				throw new Error(
					`UI dependencies are not installed at ${nodeModules}; run the documented dependency setup when online.`,
				);
			run({
				exe: "bun",
				args: ["test", "tests/e2e/quick-settings.e2e.test.js"],
				cwd: dirname(ui),
			});
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
	console.error(
		`orchestrate: ${error instanceof Error ? error.message : String(error)}`,
	);
	process.exit(1);
}
