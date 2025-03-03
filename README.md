## Wroom 🚗💨

It has absolutly nothing to do with cars or wind's and it's also not fast actually it's a blessing that the compiler even compiles.
Inspired by [Buzz](https://github.com/buzz-language/buzz)

### Next Steps

- [ ] Separate Variable and Function checks from type inference
- [ ] Check if function returns if not void
- [X] Complain when function return value is not used
- [X] Remove unnecessary external enum for expressions
- [X] Add function call as Statement
- [X] Check function call fits signature
- [ ] ~~SSA not correctly implemented~~ => optimization required
- [X] Using function parameters results in segmentation fault
- [X] Leaving the ending brace of a function results in memory leaks and multiple parser errors
- [X] X-Assigns result in weird IR and memory leak
- [ ] Errors for IRGen
- [ ] Create snippets for error
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
- [X] Fix constant expr on division =>

```
2 * 5 + 2 * 3 / 2 = 12

truncation happens too early
actual result: 13
```

### DO NOT

- ~~Binary expressions in global scope with different types. IT WILL TRIGGER THE INCORRECT MATH GODS~~ Fixed somewhat but I wouldn't trust my self with this.

### SSA

Wroom:

```
let glbl = 123 
func main(argc: int) int {
    let locl = 123 * 2 + 1 * glbl  
    return locl
}
```

IR:

```
@glbl int = #123
@main(int argc) -> int {
entry:
        %0 = alloca int
        %1 = mul int #123, #2
        %2 = load int, @glbl
        %3 = mul int #1, %2
        %4 = add int %1, %3
        store int %0, %4
        %5 = load int, %0
        return %5
}
```
