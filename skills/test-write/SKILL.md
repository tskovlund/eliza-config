# Write Tests

## When to use

- User says "write tests", "add tests", "test this", "cover this"
- New modules are added without tests
- Implementing a feature and no test file exists yet
- Do NOT use for running existing tests (just run pytest/jest directly) or debugging test failures

## Steps

### 1. Read conventions first

Read CONVENTIONS.md in the project root. The Testing section defines naming, structure, coverage, and philosophy. Every test must follow those rules exactly.

### 2. Read the source

Understand the module's public API, edge cases, and error paths.

### 3. Check for existing tests

Extend, don't duplicate. Match existing patterns.

```sh
fd "test_*" --extension py
fd --extension test.ts --extension test.js --extension spec.ts --extension spec.js
```

### 4. Write tests in priority order

1. **Happy path** — core functionality with valid inputs
2. **Edge cases** — boundary values, empty inputs, None/null, single-element collections
3. **Error paths** — invalid inputs raise appropriate exceptions with clear messages
4. **Integration points** — external interactions (API, DB, filesystem) tested with mocks/fixtures

### 5. Framework scaffolding

**Python (pytest):**

```python
# File: tests/test_<module>.py
import pytest
from <package>.<module> import <function_or_class>


class TestFunctionName:
    """Tests for function_name."""

    def test_valid_input_returns_expected(self):
        # Arrange
        input_data = create_valid_input()
        # Act
        result = function_name(input_data)
        # Assert
        assert result == expected

    @pytest.mark.parametrize("input_val,expected", [
        ("normal", "result"),
        ("edge", "edge_result"),
        ("", "empty_result"),
    ])
    def test_various_inputs_return_correct_values(self, input_val, expected):
        # Arrange / Act
        result = function_name(input_val)
        # Assert
        assert result == expected

    def test_invalid_input_raises_value_error(self):
        # Arrange
        bad_input = create_invalid_input()
        # Act / Assert
        with pytest.raises(ValueError, match="specific message"):
            function_name(bad_input)
```

**TypeScript/JavaScript (jest):**

```typescript
// File: src/<module>.test.ts
import { functionName } from "./<module>";

describe("functionName", () => {
  it("returns expected result for valid input", () => {
    // Arrange
    const input = createValidInput();
    // Act
    const result = functionName(input);
    // Assert
    expect(result).toBe(expected);
  });

  it.each([
    ["normal", "result"],
    ["edge", "edge_result"],
  ])("handles %s input", (input, expected) => {
    expect(functionName(input)).toBe(expected);
  });
});
```

### 6. Test file placement

Follow what the project already does. If no tests exist yet:

- **Python:** `tests/test_<module>.py` (mirror source structure)
- **TypeScript:** `src/<module>.test.ts` (co-located)

### 7. Run tests

Run each in a separate shell call:

```sh
# Python
pytest tests/test_<module>.py -v
```

```sh
# TypeScript
npx jest src/<module>.test.ts
```

If tests fail, fix the tests (not the source) — unless you discover an actual bug, in which case flag it to the user.

## Notes

- Naming: `test_<action>_<expected_outcome>`
- Structure: Arrange / Act / Assert comments in every test
- Lean: every test must earn its place — no trivial tests, no testing library internals
- No duplication: shared logic tested once in the base, not per subclass
- Don't test private/internal methods — test through the public API
- Don't mock everything — only mock external I/O (network, filesystem, time)
- Don't write tests that just repeat the implementation logic
- CONVENTIONS.md is the source of truth — if it has different rules, those take precedence
- Shell policy: use separate shell calls for each command — no `&&`, no redirects, no subshells

## Cross-references

- Claude Code counterpart: `/test-write`
