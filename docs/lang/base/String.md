# `lang::base::String`

### Implements  
-   `IBaseFeature`

### Depends on
-   `Safe`
-   `NotImplementedException`
-   `Vec`
-   `u8`
-   `IBaseFeature`
-   `Consumer`
-   `Iterator`
-   `debugNatives`

---

### `vec: Vec<u8>`
Contains the `String` contents.

---

### `String.new() -> String`
Creates an empty `String`.

---

### `String.from(value: string) -> String`
Creates a `String` from the specified value (`value`).

---

### `String.withCapacity() -> String`
Creates an empty `String` with reserved capacity.

---

### `String:intoBytes() -> Vec<u8>`
Returns the bytes that compose the `String`.

---

### `String:asStr() -> string`
Translates `String` into a native `string` type.

---

### `String:pushStr(append: String) -> String`
Appends the `append` value to `self`.

---

### `String:push(char: String) -> String`
Appends `char` to `self.vec`

---

### `String:remove(idx: number) -> String`
Removes the value at the specified index (`idx`).

---

### `String:pop() -> String`
Calls `self.vec:pop()`, popping the last value.

---

### `String:clear() -> String`
Calls `self.vec:clear()`, clearing the `String` instance.

---

### `[IN-DEVELOPMENT] String:iterator() -> Iterator<String>`
Returns an `Iterator<String>` of the `String` (self).

---

## Metamethods

### `add (+)`
Concats the two provided strings.

---

### `concat (..)`
Concats the two provided strings.

---

### `tostring`
Returns the `String` as a `string` by calling `self:asStr()`

---