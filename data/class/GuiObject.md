# Members

## TweenPosition

Interpolates the [Position](#memberPosition) property from its current value
to *endPosition*, for the duration of *time* seconds.

*easingDirection* indicates the timing function to be used, while
*easingStyle* indicates the interpolation function to be used.

*override* indicates whether the tween can be overridden by another tween
function. This only applies to functions that modify the Position.

If *callback* is specified, then it will be called after the tween finishes.
It receives a TweenStatus enum as its only argument. If the tween successfully
finished, then this will be `TweenStatus.Completed`. If it was overridden,
then this will be `TweenStatus.Canceled`.

This function returns whether it was able to begin tweening. If there is
another tweening function currently modifying the Position, and it cannot be
overridden, then this will return false.

If the GuiObject is not the descendant of a [DataModel](DataModel.html), then
this function will throw the following error:

	Can only tween objects in the workspace

## TweenSize

Interpolates the [Size](#memberSize) property from its current value to
*endSize*, for the duration of *time* seconds.

*easingDirection* indicates the timing function to be used, while
*easingStyle* indicates the interpolation function to be used.

*override* indicates whether the tween can be overridden by another tween
function. This only applies to functions that modify the Size.

If *callback* is specified, then it will be called after the tween finishes.
It receives a TweenStatus enum as its only argument. If the tween successfully
finished, then this will be `TweenStatus.Completed`. If it was overridden,
then this will be `TweenStatus.Canceled`.

This function returns whether it was able to begin tweening. If there is
another tweening function currently modifying the Size, and it cannot be
overridden, then this will return false.

If the GuiObject is not the descendant of a [DataModel](DataModel.html), then
this function will throw the following error:

	Can only tween objects in the workspace

## TweenSizeAndPosition

Interpolates both the [Size](#memberSize) and [Position](#memberPosition)
properties from their current values to *endSize* and *endPosition*,
respectively, for the duration of *time* seconds.

*easingDirection* indicates the timing function to be used, while
*easingStyle* indicates the interpolation function to be used.

*override* indicates whether the tween can be overridden by another tween
function. This applies to functions that modify either the Position or the
Size.

If *callback* is specified, then it will be called after the tween finishes.
It receives a TweenStatus enum as its only argument. If the tween successfully
finished, then this will be `TweenStatus.Completed`. If it was overridden,
then this will be `TweenStatus.Canceled`.

This function returns whether it was able to begin tweening. If there is
another tweening function currently modifying the Size or Position, and it
cannot be overridden, then this will return false.

If the GuiObject is not the descendant of a [DataModel](DataModel.html), then
this function will throw the following error:

	Can only tween objects in the workspace
