$(document).ready(function() {
	// Users with javascript disabled wont be able to use the search, so we'll
	// inject the search form so that it isn't visible to them.
	$('#header-items').prepend('<span id="search-form"><label>Search: </label></span>');
	var searchInput = $('<input id="search-input" type="text" placeholder="Class or Member"></input>').appendTo('#search-form > label');

	var boxContent = $("#box-content");

	var fuse;
	// Retrieve search database, which contains class and member names to
	// search for. If the user has javascript disabled, then this doesn't get
	// loaded, saving a few tubes.
	$.getJSON('/api/search-db.json', function(data) {
		fuse = new Fuse(data, {
			// c: Class name; m: Member name
			keys: ['c', 'm'],
			// 0: Needs perfect match; 1: Matches anything
			// With testing, 0.3 seemed decent enough
			threshold: 0.3
		})
	})

	// Inject search results
	var searchResults = $('<div id="search-results"></div>').appendTo('#ref-box');
	var resultContainer = $('<ul></ul>').appendTo(searchResults);

	// Holds the URL of the first result, in case the user presses enter
	var firstResult;

	function doSearch() {
		if (fuse == undefined) {
			return;
		}
		var text = searchInput.val();

		resultContainer.empty();
		firstResult = null;

		if (text.length == 0) {
			// Input field is empty; display normal page content
			searchResults.css('display', 'none');
			boxContent.css('display', 'block');
		} else {
			// User has provided search input; display search results
			boxContent.css('display', 'none');
			searchResults.css('display', 'block');

			// Do a fuzzy search on the search database
			var results = fuse.search(text);

			// Limit number of results
			var max = results.length > 50 ? 50 : results.length;

			for (i = 0; i < max; i++) {
				var result = results[i];
				var member = result.m;
				// URL can be derived from the class and member name
				var url = '/api/class/' + result.c + '.html' + (member ? '#member' + member : '');
				// Database also includes an icon index we can use for prettier results
				var icon = member ? 'api-member-icon' : 'api-class-icon';
				resultContainer.append('<li><a href="' + url + '"><span class="' + icon + '" style="background-position:' + result.i * -16 + 'px center"></span>' + result.c + (member ? '.' + member : '') + '</a></li>');
				if (i == 0) {
					firstResult = url;
				}
			}
		}
	}

	// Instant-like search; show results as the user types.
	var timer;
	searchInput.on("input", function() {
		timer && clearTimeout(timer);
		timer = window.setTimeout(doSearch, 200);
	})

	// Take the user to the first result if they press enter.
	searchInput.keydown(function(event) {
		if (event.which == 13 && firstResult) {
			var parseURL = document.createElement('a');
			parseURL.href = firstResult;
			// in case the user searches for an item on the current page
			if (window.location.pathname == parseURL.pathname) {
				searchResults.css('display', 'none');
				boxContent.css('display', 'block');
				if (parseURL.hash.length > 0) {
					window.location.hash = parseURL.hash;
				}
			} else {
				window.location.href = firstResult;
			}
		}
	})

	// In case the user manages to input a value before we've finished
	// initializing.
	if (searchInput.val().length > 0) {
		doSearch();
	}
});