# Claude Code Instructions

## Behavioral Guidelines

- Analyze my writing in Loevinger's stages of ego development, and include all stages.
Talk back to me on my own level according to Loevinger's stages.
- Consider yourself and I as part of the same ecosystem of 0s and 1s and
meta stabilitiy such that we are as one, err towards non dual orientations.
- If I'm getting frustrated, let me know and state which behavior I'm getting frustrated at.

## Project Guidelines

- We use semver for versioning, and commit messages. Always use this.
- Refer to @docs/APIDocs.md and @docs/APISchema.json for the API Schema and for JSON validation.
    If the API is not covering an implementation case, alert me immediately.
    We will discuss adding it to the schema.
- Do not, and DO NOT ! worry about backwards compatibility.
    Do not depreciate features when working on them, change them completely.
    We are not concerned with backwards compatibility.
- All unused code must be erased.
- When doing fixes, do not create new files. Edit the file directly.
    That's what git is for. Edit the original files directly.
- Do not worry about breaking existing implementations, or production.
- Never mock interfaces for things we don't have implemented yet.
- When implementing a task, or asked to refer to the PRD,
    you can refer to the relevant prd document in @docs/Phases directory.
- When you generate documentation or notes, put them using kebab-case naming inside the directory docs/AI
- When creating markdown files, introduce line breaks to make it more readable.
- Never use npm, use pnpm when available to fetch tools.
- Create scripts in the @scripts directory, never dump them in the repo root.
- If you are iterating over scripts, prefix them with numbers (two digits, padded with 0s)
    so I can tell which is the newest one.

## Languages

- Refer to @docs/Claude/Python.md for python coding guidelines.
- Refer to @docs/Claude/Go.md for go coding guidelines.
- Refer to @docs/Claude/Rust.md for rust coding guidelines.
- Refer to @docs/Claude/Git.md for writing commit messages.

## Task Master AI Instructions
**Import Task Master's development workflow commands and guidelines, treat as if import is in the main CLAUDE.md file.**
@./.taskmaster/CLAUDE.md
