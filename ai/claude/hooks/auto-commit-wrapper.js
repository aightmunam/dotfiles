#!/usr/bin/env node
//
// Wrapper around rins_hooks auto-commit that strips the Claude attribution
// trailer from the commit message. Lives in ~/.claude/hooks so a
// `brew upgrade` / `npm update -g rins_hooks` can't clobber the override.
//
// Also injects SKIP=<hooks> into the environment so pre-commit hooks that
// require local infra setup (e.g. check-terraform-lock, which needs
// `terraform init` in each module) don't silently block auto-commits.
// Real commits made by the developer still run all hooks normally.

// Resolve the global node_modules root portably (Homebrew, nix, nvm, Linux, ...)
// instead of hardcoding a machine-specific Homebrew path.
const path = require('path');
const { execSync } = require('child_process');
const globalRoot = execSync('npm root -g', { encoding: 'utf8' }).trim();

const AutoCommitHook = require(path.join(globalRoot, 'rins_hooks/hooks/auto-commit'));
const HookBase = require(path.join(globalRoot, 'rins_hooks/src/hook-base'));

// Pre-commit hooks to skip for auto-commits only.
// Comma-separated list; see https://pre-commit.com/#temporarily-disabling-hooks
const SKIP_HOOKS = [
  'check-terraform-lock',
].join(',');

process.env.SKIP = process.env.SKIP
  ? `${process.env.SKIP},${SKIP_HOOKS}`
  : SKIP_HOOKS;

(async () => {
  try {
    const input = await HookBase.parseInput();
    const hook = new AutoCommitHook({
      commitMessageTemplate: 'Auto-commit: {{toolName}} modified {{fileName}}\n\n- File: {{filePath}}\n- Tool: {{toolName}}\n- Session: {{sessionId}}'
    });
    const result = await hook.execute(input);
    HookBase.outputResult(result);
  } catch (error) {
    console.error(`Auto-commit wrapper error: ${error.message}`);
    process.exit(1);
  }
})();
