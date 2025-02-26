## Wroom 🚗💨
It has absolutly nothing to do with cars or wind's and it's also not fast actually it's a blessing that the compiler even compiles. 
Inspired by [Buzz](https://github.com/buzz-language/buzz)

### Next Steps

- [ ] Create snippets for error
- [X] Add function body
- [X] Create Statment tagged union
- [X] Parse parameters
- [ ] Add void type
- [ ] Add checking for void type
- [ ] Variable shadowing
- [X] Return statement
- [X] Assign to already declared variable
- [X] Illegal assignment on undeclared variable 
- [ ] Fix case where position is 0 because body is empty
- [~] Fix constant expr on division => 
```
2 * 5 + 2 * 3 / 2 = 12

truncation happens too early
actual result: 13
```

### DO NOT 
- ~~Binary expressions in global scope with different types. IT WILL TRIGGER THE INCORRECT MATH GODS~~ Fixed somewhat but I wouldn't trust my self with this.