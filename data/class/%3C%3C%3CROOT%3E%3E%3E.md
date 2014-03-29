# Summary

**&lt;&lt;&lt;ROOT&gt;&gt;&gt;** was an abstract class that all classes,
including [Instance](Instance.html), inherited from.

# Details

&lt;&lt;&lt;ROOT&gt;&gt;&gt; was removed the API dump, so classes no longer
appear to inherit from it. However, it can still be exposed through the
[Instance.IsA](Instance.html#memberIsA) function. That is, passing the name of
this class as an argument to IsA will return `true`.

	print(object:IsA('<<<ROOT>>>')) --> true
