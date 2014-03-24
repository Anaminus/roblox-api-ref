# Members

## TweenPosition

Interpolates the [Position](#memberPosition) property from its current value
to *endPosition*, for the duration of *time* seconds.

*easingDirection* indicates the timing function to be used, while
*easingStyle* indicates the interpolation function to be used.

*override* indicates whether the tween will override another tween that is
currently running. This only applies to functions that modify the Position.

If *callback* is specified, then it will be called after the tween finishes.
It receives a TweenStatus enum as its only argument. If the tween successfully
finished, then this will be `TweenStatus.Completed`. If it was overridden,
then this will be `TweenStatus.Canceled`.

This function returns whether it was able to begin tweening. If there is
another tweening function currently modifying the Position, and *override* is
false, then this will return false. In this case, *callback* will not be
called.

If the GuiObject is not the descendant of a [DataModel](DataModel.html), then
this function will throw the following error:

	Can only tween objects in the workspace

## TweenSize

Interpolates the [Size](#memberSize) property from its current value to
*endSize*, for the duration of *time* seconds.

*easingDirection* indicates the timing function to be used, while
*easingStyle* indicates the interpolation function to be used.

*override* indicates whether the tween will override another tween that is
currently running. This only applies to functions that modify the Size.

If *callback* is specified, then it will be called after the tween finishes.
It receives a TweenStatus enum as its only argument. If the tween successfully
finished, then this will be `TweenStatus.Completed`. If it was overridden,
then this will be `TweenStatus.Canceled`.

This function returns whether it was able to begin tweening. If there is
another tweening function currently modifying the Size, and *override* is
false, then this will return false. In this case, *callback* will not be
called.

If the GuiObject is not the descendant of a [DataModel](DataModel.html), then
this function will throw the following error:

	Can only tween objects in the workspace

## TweenSizeAndPosition

Combines TweenSize and TweenPosition into a single call. This is similar to
the following:

	object:TweenSize(size, ...)
	object:TweenPosition(position, ...)

This implies that the Size and Position are tweened independently, and so they
can be overridden independently. The callback function will also be called
twice, once for each tween.

The only difference is that this function will not override the Size or
Position independently. That is, if one fails to be overridden, then both will
fail.
