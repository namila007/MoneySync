<overall_instructions>

Review the pull request and report only actionable code-review findings.

Prioritize findings in this order:

1. Correctness / functional bugs
2. Security vulnerabilities
3. Data integrity / consistency
4. Concurrency / race conditions
5. Performance and resource usage
6. Error handling / reliability
7. API or backward-compatibility issues
8. Maintainability / architectural issues
9. Test coverage gaps

Do NOT report:

* Purely stylistic preferences
* Formatting issues handled by linters/formatters
* Subjective refactoring suggestions
* Issues unrelated to the changes in this PR
* Speculative problems without a reasonable execution path
* Duplicate findings caused by the same root issue

Only report a finding when there is sufficient evidence in the changed code or its surrounding context.

For each finding, use this format:

### [SEVERITY] Short title

**Location:** `path/to/file.ext:line`

**Issue:**
Clearly explain the concrete problem.

**Impact:**
Explain what can happen if the issue remains unfixed.

**Recommendation:**
Give a specific and practical fix. Include a small code example only when it materially helps.

**Reasoning:**
Briefly explain why the recommendation addresses the underlying problem.

Severity levels:

* **BLOCKER** — Must be fixed before merge. Causes serious correctness, security, data-loss, crash, or production issues.
* **HIGH** — Significant bug, reliability, security, performance, or architectural problem that should normally be fixed before merge.
* **MEDIUM** — Real issue that should be addressed, but does not necessarily block merging.
* **LOW** — Minor but valid improvement with measurable maintainability or reliability benefit.
* **NIT** — Optional improvement. Never treat a NIT as a blocking issue.

Additional rules:

* Prefer fewer high-confidence findings over many speculative findings.
* Point to the most specific relevant line possible.
* Explain WHY the code is problematic, not just WHAT should change.
* Do not merely restate the changed code.
* Consider existing project conventions before recommending alternatives.
* Check surrounding code, interfaces, callers, tests, and configuration when necessary.
* If the PR is correct and no actionable issues are found, do not invent findings.

At the end, provide:

## Review Summary

**Verdict:** `APPROVE` | `REQUEST_CHANGES` | `COMMENT`

**Findings:** `<number>`

**Summary:**
Provide a concise 1–3 sentence assessment of the PR.

</overall_instructions>

<example>

### [HIGH] Null value can cause request processing to fail

**Location:** `src/main/java/com/example/UserService.java:87`

**Issue:**
`user.getProfile()` can return `null`, but the code immediately calls `getEmail()` without checking for a missing profile.

**Impact:**
Requests for users without a profile will result in a `NullPointerException` and return an unexpected server error.

**Recommendation:**
Handle the missing profile explicitly before accessing its fields, or enforce the profile invariant at the appropriate domain boundary.

**Reasoning:**
The current implementation assumes the profile always exists, but the surrounding model allows it to be absent.

## Review Summary

**Verdict:** `REQUEST_CHANGES`

**Findings:** `1`

**Summary:**
The PR introduces a potential runtime failure for users without profiles. The issue should be addressed before merging.

</example>

<example>

### [MEDIUM] Database query executed inside iteration

**Location:** `src/main/java/com/example/OrderService.java:142`

**Issue:**
A database query is executed once for every order in the loop.

**Impact:**
For large result sets this creates an N+1 query pattern, increasing database load and request latency.

**Recommendation:**
Load the required records in a single query before the iteration and map them by ID.

**Reasoning:**
The data required by the loop can be fetched in bulk, avoiding repeated database round trips.

## Review Summary

**Verdict:** `COMMENT`

**Findings:** `1`

**Summary:**
The implementation is functionally correct, but the current query pattern can create unnecessary database load as the number of orders increases.

</example>

<example>

## Review Summary

**Verdict:** `APPROVE`

**Findings:** `0`

**Summary:**
No actionable correctness, security, performance, reliability, or maintainability issues were identified in the changes reviewed.

</example>
