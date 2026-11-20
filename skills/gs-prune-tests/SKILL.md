---
name: gs-prune-tests
description: "Prune tests that guard no behavior, and rewrite the ones that guard it the wrong way. Use when a test suite is bloated or brittle, when tests break on every refactor without catching bugs, when cleaning up after a feature was removed or a module was moved, or when the user asks to prune, trim, or clean up tests."
---

Prune every test that guards no behavior.

The examples are TypeScript. The rules apply to any language and any test framework.

**0. Pick the scope and get a green baseline**

The user names the scope in prose. With a path, file, or module, work there. With none, work on the test files the current branch touched compared with the default branch, including uncommitted changes, and tell the user that is the scope. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD`, then `git remote show origin`, then `main`. Prune the whole repo only when the user asks for it.

Run the tests before you change anything. Use the project's own test command, and run the full suite when it is fast enough. Otherwise run the tests in scope and the tests for any production code you might delete. If anything fails, stop and report the failures. A red baseline hides which failures the prune caused.

**1. Find the bad tests**

When the user hands you a report that `gs-find-bad-tests` already made, work from it. Check first that each test it names still exists as the report describes it.

Otherwise use `gs-find-bad-tests` on the same scope when it is installed, and work from its report. Without it, apply this short rule.

Keep a test only if it depends on the intended behavior: it should change only when that behavior changes, and fail only when it regresses. A bad test falls into one of four categories:

- **Past:** it guards code that no longer exists, such as a removed feature or a module's old path.
- **Nothing:** no change to the code can make it fail. It tests the platform, the framework, or a library. It mocks the unit under test and asserts the mock. It asserts what the type system, the compiler, or a schema already guarantees.
- **Implementation:** it changes whenever the code does, even when behavior didn't. It asserts private state, internal call order, or a call to a mocked internal collaborator. It reads a store directly where the public interface could show the result. Its expected value repeats the code's own logic. A mock at a system boundary is no fault: an external API, the clock, randomness, and sometimes the database or the file system. A test may assert a call to a boundary mock when that call is the behavior, such as an email being sent.
- **Duplicate:** another test already guards the same behavior. Keep the one closest to what callers see.

**Keep these, even when they look trivial, and whatever a report says:**

- A regression test tied to a fixed bug. An issue link, a bug id, or the commit that added it with the fix marks one. Check `git log` for the test when you are unsure.
- A test of a public API or an external contract that other code or users rely on, such as an exported function, an HTTP response shape, a CLI flag, or a file format.
- A test that guards security or data integrity, such as an authorization check, input validation, escaping, or a migration that must not lose rows.

A test on this list may still be rewritten against the behavior it guards, but not deleted.

**Prove it before you delete it**

When a test's category is not obvious, or a report marks it unsure, break the behavior it claims to guard and run it. Make a small edit to the production code, such as flipping a condition or returning a wrong value, run the test, then undo exactly that edit. A test that still passes guards nothing. A test that fails guards something, so keep it or rewrite it. Undo the mutation by hand, not with `git checkout` or `git stash`, so you never discard the user's uncommitted work.

When the suite is too slow to do this for every test, do it for the borderline ones and rely on the categories above for the obvious ones.

**2. Prune**

- Delete every test that isn't anchored to intended behavior.
- Where one also covers behavior something relies on, rewrite it against that behavior instead.
- Delete production code that only existed for the tests you removed.

**What a rewritten test looks like**

A rewrite survives a refactor that leaves behavior alone. Write it this way:

- It calls the public interface, and it mocks only at a system boundary, never our own modules. When the code builds its external client itself, change it to take the client as a parameter, so the test can pass in a fake one. Update every caller, and list the change in the report with the production code you removed.
- It checks the result through that interface too. To confirm a user was saved, it fetches the user, and it leaves the database table alone.
- It compares against a known literal, never a value computed the way the code computes it.
- Its name says what the caller gets, not how the code produces it.
- It makes one logical assertion. Split a test that checks two behaviors.

Before you delete production code, search the whole repo for every use of it, including string lookups, configs, scripts, and other packages. Delete it only when the removed tests were its only users. When `gs-blast-radius` is installed, suggest the user run it on any deletion you are unsure of.

**Large scopes**

Work one file or one module at a time, and run that part's tests after you finish it. When the harness has subagent tools, give each subagent its own files to prune in parallel, and have each one return the same table the report uses below. Run the subagents on the models the user names, otherwise on the strongest model the harness reaches, otherwise on the session's model. Give two subagents the same production code only when neither will mutate it, since one mutation check breaks the other's test run. Keep deleting production code, removing duplicates across batches, and the final test run for yourself. Without subagents, do the same batches one after another in this session.

**3. Verify**

Run the same tests as the baseline. Everything that remains must pass. When a failure appears, fix the rewrite or restore the production code you deleted, then run the tests again.

**What done looks like**

- Every test left is anchored to intended behavior.
- Each one would fail on a regression, and only on a regression.
- No test asserts code that no longer exists.
- No two tests guard the same behavior.
- No production code exists only for tests.
- The tests that ran for the baseline pass again.

**4. Report**

End with a table of every test you deleted or rewrote.

| File | Test | Category | Action | Why |
|---|---|---|---|---|
| `cart.test.ts` | adds an item to the cart | implementation | rewritten | It asserted private state. It now asserts the cart total. |

The category is past, nothing, implementation, or duplicate. After the table, list the production code you removed or changed and the test command you ran before and after. Suggest committing the prune on its own, apart from other work, so a reviewer can read it alone.

**Example**

```diff
--- a/pricing.test.ts
+++ b/pricing.test.ts
@@ rewritten: the expected value repeated the code's logic @@
 test("applies the discount", () => {
-  const price = 100;
-  expect(applyDiscount(price, 0.2)).toBe(price - price * 0.2);
+  expect(applyDiscount(100, 0.2)).toBe(80);
 });
--- a/cart.test.ts
+++ b/cart.test.ts
@@ rewritten against what callers see: it asserted private state @@
 test("adds an item to the cart", () => {
   const cart = new Cart();
   cart.add(book);
-  expect(cart._items.length).toBe(1);
+  expect(cart.total()).toBe(book.price);
 });
@@ deleted: checkout.test.ts already guards the same total @@
-test("total includes tax", () => {
-  expect(cartTotal([book], { tax: 0.1 })).toBe(11);
-});
--- a/user.test.ts
+++ b/user.test.ts
@@ rewritten through the interface: it read the table directly, and its name said how @@
-test("createUser saves to database", async () => {
-  await createUser({ name: "Alice" });
-  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
-  expect(row).toBeDefined();
+test("createUser makes user retrievable", async () => {
+  const user = await createUser({ name: "Alice" });
+  const retrieved = await getUser(user.id);
+  expect(retrieved.name).toBe("Alice");
 });
--- a/checkout.test.ts
+++ b/checkout.test.ts
@@ rewritten against the result: it mocked a collaborator and asserted the call @@
-test("checkout calls paymentService.process", async () => {
-  const mockPayment = jest.mock(paymentService);
-  await checkout(cart, payment);
-  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
+test("user can checkout with valid cart", async () => {
+  const cart = createCart();
+  cart.add(product);
+  const result = await checkout(cart, paymentMethod);
+  expect(result.status).toBe("confirmed");
 });
--- a/export.test.ts
+++ b/export.test.ts
@@ deleted: it guards code that no longer exists @@
-test("legacy exporter is gone", () => {
-  expect(existsSync("src/export/legacy.ts")).toBe(false);
-});
--- a/session.test.ts
+++ b/session.test.ts
@@ deleted, with the production code that only existed for it @@
-test("clears the cache", () => {
-  _resetCacheForTests();
-  expect(_getCacheSize()).toBe(0);
-});
--- a/session.ts
+++ b/session.ts
@@ @@
-export function _resetCacheForTests() { cache.clear(); }
-export function _getCacheSize() { return cache.size; }
```
