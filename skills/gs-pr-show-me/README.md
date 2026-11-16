# gs-pr-show-me

This skill explains what a pull request changes, in plain language with small pictures. It reads the pull request and its diff, then prints what changed, how it works, where to look first, what could break, and what evidence the pull request carries. It posts nothing and changes nothing.

This skill is original to this repo. It uses two other skills from this repo:

- [`gs-pull-request`](../gs-pull-request/README.md) supplies the shape of the explanation. `gs-pull-request` writes that shape for the author. This skill fills it in from the reviewer's side, and adds a list of where to look first.
- [`gs-show-me`](../gs-show-me/README.md) chooses and draws the pictures.

When either skill is not installed, a short set of fallback rules in this skill applies.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-pr-show-me
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-pr-show-me
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-pr-show-me                      # the pull request for the current branch
/gs-pr-show-me 482                  # a pull request by number
/gs-pr-show-me 482 the migration    # focus on one part
```

The agent can also start it on its own, when you ask to be walked through a pull request. To post comments on the pull request, use `gs-pr-comment`. To look for defects, use `gs-review`.
