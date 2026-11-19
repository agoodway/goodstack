# gs-git-commit

This skill commits the current changes. It writes conventional commit messages, skips secrets and generated files, and adds no AI attribution. It has no subcommands and does not open a pull request.

It leaves these unstaged: OS and editor junk, build output such as `node_modules/` and `dist/`, logs and temp files, `.env` files other than `.env.sample` and `.env.example`, `credentials.*`, and anything `.gitignore` already covers.

## Use cases

- You finished a change and want it committed with a conventional message and no AI attribution.
- Your working tree holds `.env` files, build output, or logs, and you want a commit that leaves them out.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-git-commit
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-git-commit
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

`/gs-git-commit` reviews the working tree, skips the files above, and commits what remains. A message after the command becomes the commit description. The skill asks before it pushes. Opening the pull request is `/gs-pull-request`.
