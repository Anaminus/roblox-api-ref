# Summary

The **TestService** can be used for performing unit tests, as well as testing
a place with various settings.

# Details

Each method used for testing may emit a message to the output. This message
begins with "TestService", indicating that it was emitted by a TestService
method. A message may be an error (in red), a warning (in yellow), or a
regular message (in blue).

Each test method also allows a *source* and a *line* to be optionally supplied
as arguments. If they are given, then they are displayed in the message.

The *source* argument indicates a [script](BaseScript.html) object
related to the message (such as the script where an error occurred). The
script's [Name](Instance.html#memberName) is displayed before the
main description or text of the message. Note that *source* may be any
instance, not just a script.

*line* indicates an exact line in the script related to the message. If
*source* is given, then the line is displayed after the source name. If not,
then the line is not displayed.

Example messages:

*Without source:*

	TestService: message

*With source (SourceName) and line (123):*

	TestService.SourceName(123): message

# Members

## TestCount

Indicates the number of assertions that have been made during a test.

## WarnCount

Indicates the number of warnings that have occurred during a test.

## ErrorCount

Indicates the number of errors and fatal errors that have occurred during a
test.

## Timeout

The amount of time, in seconds, in which a test must be completed.

## Run

Used to begin a test. When called, all counters are reset, and the current
thread is yielded until [Done](#memberDone) is called, or Timeout is reached.

If the test is completed, a regular message displays the number of tests,
warnings, and errors that occurred during the test. If no assertions were made
(i.e. if test count is 0), then a message indicating such will be displayed
instead.

If [Done](#memberDone) is not called within the time limit, then an error
message indicating such will be displayed.

## Check

Tests *condition*. If the condition is false, *description* is displayed as an
error message in the output, and the [ErrorCount](#memberErrorCount) property
is incremented.

Calling this method increments the [TestCount](#memberTestCount) property.

## Error

Unconditionally displays *description* as an error message in the output, and
increments the [ErrorCount](#memberErrorCount) property.

Calling this method increments the [TestCount](#memberTestCount) property.

## Fail

Unconditionally displays *description* as a fatal error message in the output,
and increments the [ErrorCount](#memberErrorCount) property.

Calling this method increments the [TestCount](#memberTestCount) property.

## Checkpoint

Displays *text* as a checkpoint message in the output.

## Message

Displays *text* as a regular message in the output.

## Require

Tests *condition*. If the condition is false, *description* is displayed as a
fatal error message in the output, and the [ErrorCount](#memberErrorCount)
property is incremented.

Calling this method increments the [TestCount](#memberTestCount) property.

## Warn

Tests *condition*. If the condition is false, *description* is displayed as a
warning message in the output, and the [WarnCount](#memberWarnCount) property
is incremented.

Calling this method increments the [TestCount](#memberTestCount) property.

## Done

When performing a test with [Run](#memberRun), the test can be completed by
calling this method.
