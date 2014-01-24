$(document).ready(function(){
	$('#diff-versions > li').each(function(){
		var list = $(this).children('.diff-list');
		var a = $(this).children('a.anchor:target')
		if (a.length == 0) {
			// Collapse the diff's list if the diff has not been targeted by
			// the URL. By navigating to a URL that targets a specific diff,
			// only that diff's list will be expanded when the page has
			// loaded.
			list.hide();
		} else {
			// The browser usually scrolls right to a target, but that gets
			// skewed by the lists being hidden. Since this is the diff being
			// targeted, re-scroll to it.
			$(document).scrollTop(a.offset().top);
		}
		$(this).children('.diff-date').css('cursor','pointer').click(function(){
			list.toggle();
		});
	});
});
