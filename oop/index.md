# Objects and Classes

## Outline

- Define a `Shape` typeclass specifying `area` and `perimeter` for any type
- Implement `Circle` and `Square` as plain structures
- Provide typeclass instances for each; no shared base class needed
- Write a polymorphic `describe` function constrained by `[Shape α]`
- Demonstrate that any type satisfying the contract is usable interchangeably

## Code

[%inc code.lean %]
