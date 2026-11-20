---
name: gs-find-bad-tests
description: "Find the tests that guard no behavior and report them, without changing any file. Use when the user asks to find bad tests, audit a test suite, asks which tests are worth keeping or which could be pruned, wants a report before pruning, or names gs-find-bad-tests. To delete or rewrite the tests, use gs-prune-tests."
---

Find every test that guards no behavior, and report it. Change no file.

The examples are TypeScript. The rules apply to any language and any test framework.

**0. Pick the scope**

The user names the scope in prose. With a path, file, or module, work there. With none, work on the test files the current branch touched compared with the default branch, including uncommitted changes, and tell the user that is the scope. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD`, then `git remote show origin`, then `main`. Read the whole repo only when the user asks for it.

**1. Find what each test depends on**

Read every test in scope, and the production code it exercises. A good test depends on the intended behavior: it should change only when that behavior changes, and fail only when it regresses.

Report a test that depends on anything else. There are four categories.

**The past:** it guards code that no longer exists, so it has no reason of its own to change.

For example:

- A feature was removed, and tests assert it's gone. Removed code never changes, so they can't catch a regression.
- A module was moved, and a test asserts it's absent from its old path.

**Nothing:** no change to the code can make it fail, so it has no reason of its own to change.

For example:

- It tests the platform, the framework, or a library, which are already tested. A button element renders, or a click event fires. An ORM insert writes a row, or a schema has the field its definition declares.
- It mocks the unit under test, then asserts what the mock returns.
- It asserts what the type system already guarantees. In a language without static types, it asserts what the compiler, a struct definition, or a schema already enforces.

**The implementation:** it changes whenever the code does, even when behavior didn't.

For example:

- The expected value is derived from the same logic as the code, so a wrong result still passes.
- It asserts private state, internal call order, or which helper was invoked.
- It mocks an internal collaborator, then asserts that the code called it, how many times, or with what.
- It reads a database row or another store directly to check a result the public interface could show. When the stored data is itself the contract, such as a migration or a file format, the keep list below applies.

A test name that says how the code works, such as "checkout calls paymentService.process", is a sign of this category. Read the assertions before you decide, since the name alone proves nothing.

**Judge a mock by where it sits.** A mock at a system boundary is no fault. A mock of anything we control is.

- A boundary is something outside the system: an external API such as payment or email, the clock, randomness, and sometimes the database or the file system. A test database is better than a mocked one.
- Anything we control is not a boundary: our own classes and modules, and internal collaborators.

A test that mocks a boundary and asserts the call to it is good when that call is the behavior, such as an email being sent or a card being charged. A test that mocks our own module and asserts the call belongs in this category.

A mock that branches on its arguments to choose a reply is a sign that the boundary is one generic function, such as a single `fetch(endpoint, options)` wrapper. Report the test only when it also fits a category. Name the wrapper in the report, since one function for each external operation would give each mock one shape.

**A duplicate:** another test already guards the same behavior. Report the copy, and name the test that stays. The one that stays is the one closest to what callers see.

```typescript
// The past: the legacy exporter was removed
test("legacy exporter is gone", () => {
  expect(existsSync("src/export/legacy.ts")).toBe(false);
});

// Nothing: the mock answers, and the test asserts the mock
test("getUser returns the user", async () => {
  jest.spyOn(users, "getUser").mockResolvedValue(alice);
  expect(await users.getUser(1)).toBe(alice);
});

// The implementation: the expected value repeats the code's logic
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// The implementation: it mocks a collaborator and asserts the call
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});

// The implementation: it reads the table, not the interface
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});
```

**Never mark these for deletion, even when they look trivial:**

- A regression test tied to a fixed bug. An issue link, a bug id, or the commit that added it with the fix marks one. Check `git log` for the test when you are unsure.
- A test of a public API or an external contract that other code or users rely on, such as an exported function, an HTTP response shape, a CLI flag, or a file format.
- A test that guards security or data integrity, such as an authorization check, input validation, escaping, or a migration that must not lose rows.

A test on this list may be marked for a rewrite against the behavior it guards.

**2. Give each bad test a verdict**

- **delete:** nothing relies on what the test covers, or another test already guards it.
- **rewrite:** the test covers behavior something relies on, but it asserts it the wrong way. Say what the rewrite should assert. A good rewrite calls the public interface, checks the result through that interface, compares against a known literal, has a name that says what the caller gets, and makes one logical assertion. It mocks only at a system boundary.

  Some tests mock internals because the code leaves no other way in. The code builds its external client itself, so a test cannot pass in a fake one. Say so in the row: the rewrite needs the production code to take that dependency as a parameter first.

  ```typescript
  // The test can pass in a fake paymentClient
  function processPayment(order, paymentClient) {
    return paymentClient.charge(order.total);
  }

  // The test cannot reach the client, so it mocks around it
  function processPayment(order) {
    const client = new StripeClient(process.env.STRIPE_KEY);
    return client.charge(order.total);
  }
  ```
- **unsure:** you cannot tell from reading whether the test can fail. Say which change to the production code would settle it. Do not make that change yourself.

Then look for production code that only the bad tests use, such as a reset helper exported for tests. Search the whole repo for every use of it, including string lookups, configs, scripts, and other packages. List it only when the tests marked for deletion are its only users.

**Large scopes**

Work one file or one module at a time. When the harness has subagent tools, give each subagent its own files to read in parallel, and have each one return the same table the report uses below. Run the subagents on the models the user names, otherwise on the strongest model the harness reaches, otherwise on the session's model. Keep finding duplicates across batches for yourself, since no single subagent sees both copies. Without subagents, read the same batches one after another in this session.

**3. Report**

Start with the scope, the number of tests you read, and the number you found bad. Then give a table of every bad test.

| File | Test | Category | Verdict | Why |
|---|---|---|---|---|
| `cart.test.ts` | adds an item to the cart | implementation | rewrite | It asserts private state. It should assert the cart total. |
| `export.test.ts` | legacy exporter is gone | past | delete | The legacy exporter was removed. |
| `cart.test.ts` | total includes tax | duplicate | delete | `checkout.test.ts` "charges tax on the total" guards the same total. |
| `session.test.ts` | clears the cache | nothing | unsure | Make `clear()` a no-op and run the test. If it still passes, it guards nothing. |

The category is past, nothing, implementation, or duplicate. After the table, list the production code that exists only for the tests marked for deletion.

When no test in scope is bad, say so, and give the scope and the count you read.

End by saying how to act on the report. When `gs-prune-tests` is installed, tell the user it takes this report and does the deleting and rewriting. Without it, the user deletes and rewrites by hand, and runs the tests before and after.
