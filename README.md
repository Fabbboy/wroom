## Wroom 🚗💨

It has absolutly nothing to do with cars or wind's and it's also not fast actually it's a blessing that the compiler even compiles.
Inspired by [Buzz](https://github.com/buzz-language/buzz)

## ⚠️Important⚠️

In favor of a better and more stable IR I decided to put this project on ice until I built a more stable and better IR. After that the IR system will be completely rewritten.

### Next Steps

- [ ] Add alignment to IR
- [ ] Split globals and global constants in module
- [ ] Prevent values and enforce types for extern variables
- [ ] Remove global from IRValue
- [ ] Better error messages please
- [ ] ~~Create snippets for error~~ => string formating is \*\*\*\*
- [x] Bug: You can create void variables implicitly through a function which returns void
- [x] Constants
- [x] Different linkages
- [ ] Separate Variable and Function checks from type inference
- [ ] Check if function returns if not void
- [x] Complain when function return value is not used
- [x] Remove unnecessary external enum for expressions
- [x] Add function call as Statement
- [x] Check function call fits signature
- [ ] ~~SSA not correctly implemented~~ => optimization required
- [x] Using function parameters results in segmentation fault
- [x] Leaving the ending brace of a function results in memory leaks and multiple parser errors
- [x] X-Assigns result in weird IR and memory leak
- [x] Errors for IRGen
- [x] Add function body
- [x] Create Statment tagged union
- [x] Parse parameters
- [x] Add void type
- [x] Add checking for void type
- [~] Variable shadowing => Implicitly works didn't specifically implement it
- [x] Return statement
- [x] Assign to already declared variable
- [x] Illegal assignment on undeclared variable
- [ ] Fix case where position is 0 because body is empty
- [x] ~~Costexpr doesn't really allow implicit floats anymore~~ => is actually expected behaviour
- [x] Fix constant expr on division =>

```
2 * 5 + 2 * 3 / 2 = 12

truncation happens too early
actual result: 13
```

### DO NOT

- ~~Binary expressions in global scope with different types. IT WILL TRIGGER THE INCORRECT MATH GODS~~ Fixed somewhat but I wouldn't trust my self with this.

### SSA

#### Simple expressions

Wroom:

```
let glbl = 123
func main(argc: int) int {
    let locl = 123 * 2 + 1 * glbl
    return locl
}
```

IR:

```llvm
@glbl i32 = #123
@main(i32 argc) -> i32 {
entry:
        %0 = alloca i32
        %1 = mul i32 #123, #2
        %2 = load i32, @glbl
        %3 = mul i32 #1, %2
        %4 = add i32 %1, %3
        store i32 %0, %4
        %5 = load i32, %0
        return %5
}
```

#### Function calls

Wroom:

```
func multiply(a: int) int {
    return 2 * a
}

func main() int {
    let wtf = multiply(69420)
    return wtf
}
```

IR:

```llvm
@multiply(a i32) -> i32 {
entry:
        %0 = load i32, @a
        %1 = mul i32 #2, %0
        return %1
}
@main() -> i32 {
entry:
        %0 = alloca i32
        %1 = call @multiply(#69420)
        store i32 %0, %1
        %2 = load i32, %0
        return %2
}
```
