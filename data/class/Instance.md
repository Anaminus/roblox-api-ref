# Members

## Archivable

Determines whether the object can be serialzed. If *false*, then the object
will not be included when saved in a place or model, or when being cloned with
[Instance.Clone](#memberClone).

## Clone

Returns a copy of the object, including all descendants. The properties of
each object are copied.

## ChildAdded

Fired after a child has been added to the object.

- *child*: The object that was added as a child to the object.

## FindFirstChild

Returns the first child in the object whose [Name](#memberName) is *name*, or
nil if the child cannot be found. If *recursive* is true, FindFirstChild will
also be called on each of the object's children, effectively searching for the
first descendant of the object.
