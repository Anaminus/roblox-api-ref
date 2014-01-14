$(document).ready(function(){
	$('#diff-versions > li').each(function(){
		var list = $(this).children('.diff-list');
		if (this.id != 'latest') {
			list.hide();
		}
		$(this).children('.diff-date').css('cursor','pointer').click(function(){
			list.toggle();
		});
	});
});
