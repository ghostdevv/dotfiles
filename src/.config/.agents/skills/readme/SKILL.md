---
name: Create a README.md
description: Generate or update a concise README for the project
---

Explore the project first — read `package.json`, the file tree, any Dockerfile, config files, and existing docs — so the README is grounded in reality. Then generate or update a concise README.md. Keep it simple, clear, and practical. Write in British English (e.g. "analyse" not "analyze", "colour" not "color", "organisation" not "organization"). Adapt sections to what the project actually has; don't force sections that don't apply.

1. **Read the project**: check `package.json` (name, scripts, package manager, dependencies), file structure, framework markers, Docker files, env files, and any existing README.md.
2. **If a README already exists**, read it and update it in place — preserve useful content the user has written.
3. **Write the README** using the template below as a starting point, adding or removing sections as needed.

```md
# project name, usually the repo name in kebab case

One-line description of what this project does and why it exists.

## Running

System-level dependencies only (e.g. Node 22+, pnpm). Skip universal tools like `git` or a text editor. Followed by quick commands to get the project running locally. Include install, setup, and run steps - no need to document every command just the essentials. Write this section as a sentence, but you can use a code block if you're showing multiple commands.

## Configuration

If the project uses `.env` or similar, list required variables with brief descriptions. Remove this section if not applicable.

## How it works or What it does

If the short description isn't adequate you can include a longer but similarly concise explanation of the project here.
```
