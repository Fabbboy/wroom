## Wroom 🚗💨
It has absolutly nothing to do with cars or wind's and it's also not fast actually it's a blessing that the compiler even compiles. 
Inspired by [Buzz](https://github.com/buzz-language/buzz)

### Next Steps

- [ ] Create snippets for error
- [X] Add function body
- [X] Create Statment tagged union
- [X] Parse parameters
- [X] Add void type
- [X] Add checking for void type
- [~] Variable shadowing => Implicitly works didn't specifically implement it
- [X] Return statement
- [X] Assign to already declared variable
- [X] Illegal assignment on undeclared variable 
- [ ] Fix case where position is 0 because body is empty
- [X] ~~Costexpr doesn't really allow implicit floats anymore~~ => is actually expected behaviour
- [~] Fix constant expr on division => 
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
func main() int {
    let i = 123
    i += 1
}
```

IR:
```
@main() -> int {
    %i1 = alloca int
    store int $123, ptr %1

    %i2 = load int, ptr %1
    %i3 = add int %i2, int $1
    
    store i32 %i3, ptr %i1
}
```