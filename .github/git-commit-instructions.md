Avoid overly verbose descriptions or unnecessary details.

Use conventional commits.

Use types without scopes: feat, fix, chore, docs, style, refactor, perf, test, ci, build

Format the subject as an imperative sentence no more than 50 characters, starting with <type>: and no trailing period

Leave exactly one blank line after the subject

In the body write two or three sentences max explaining what changed and why, using present tense

Avoid unnecessary verbosity; focus on intent and impact

Example:
feat: add user login endpoint

Implements the /login API with JWT authentication and email/password validation. Returns HTTP 401 on invalid credentials and embeds the token in the response.