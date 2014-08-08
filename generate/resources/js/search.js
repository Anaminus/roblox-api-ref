function compare(exp) {
	if (exp) {
		return -1;
	} else {
		return 1;
	}
}

var entityMap = {
	"&": "&amp;",
	"<": "&lt;",
	">": "&gt;",
	'"': '&quot;',
	"'": '&#39;',
	"/": '&#x2F;'
};

function escapeHTML(string) {
	return String(string).replace(/[&<>"'\/]/g, function(s) {
		return entityMap[s];
	});
}

function fuzzSort(a, b) {
	if (a[1] !== b[1]) {
		// Sort by between-score. This prefers items whose matched characters
		// are more grouped together.
		return compare(a[1] < b[1]);
	}

	if (a[2] !== b[2]) {
		// Sort by start-score. This prefers items whose first matched
		// character is towards the start of the item.
		return compare(a[2] < b[2]);
	}

	if (a[3].length !== b[3].length) {
		// Sort by length of strings. Items with shorter lengths will be
		// closer to the length of the original query.
		return compare(a[3].length < b[3].length);
	}

	// If all else fails, sort alphabetically.
	return compare(a[3] < b[3]);
}

// query: A string.
// items: An array of objects.
// p:     The property to get from each object in the array.
function Fuzzy(query, items) {
	// Convert to lowercase; ignore unimportant characters.
	query = query.toLowerCase().replace(/[^\w><]/g, '');

	// Generate pattern that matches any characters between each query
	// character.
	var pattern = '^.*?';
	for (i = 0; i < query.length; i++) {
		pattern += query[i] + '.*?';
	}
	pattern += '$';

	var regex = new RegExp(pattern);
	var sorted = new Array();
	for (i = 0; i < items.length; i++) {
		var item = items[i];

		// Select either the member name or the class name to compare with the
		// query.
		var text = item.m ? item.m.toLowerCase() : item.c.toLowerCase();

		regex.lastIndex = 0;
		if (!regex.test(text)) {
			continue;
		}

		// Next start position.
		var s = 0;
		// Between-score; total amount of characters between each matched
		// query character.
		var bScore = 0;
		// Start-score; number of characters before first matched query
		// character.
		var sScore = 0;
		// List of indices that should be highlighted
		var highlight = new Array();

		// Find index of each query character to tally scores.
		for (var q = 0; q < query.length; q++) {
			var w = text.indexOf(query[q], s);
			if (q == 0) {
				sScore = w - s;
			} else {
				bScore += w - s;
			}

			highlight.push(w);
			s = w + 1;
		}

		sorted.push([item, bScore, sScore, text, highlight]);
	}

	sorted.sort(fuzzSort);

	return sorted;
}


$(document).ready(function() {
	// Users with javascript disabled wont be able to use the search, so we'll
	// inject the search form so that it isn't visible to them.
	$('#header-items').prepend('<span id="search-form"><label>Search: </label></span>');
	var searchInput = $('<input id="search-input" type="text" placeholder="Class or Member"></input>').appendTo('#search-form > label');

	var boxContent = $("#box-content");

	var searchData;
	// Retrieve search database, which contains class and member names to
	// search for. If the user has javascript disabled, then this doesn't get
	// loaded, saving a few tubes.
	$.getJSON('/api/search-db.json', function(data) {
		searchData = data
	})

	// Inject search results
	var searchResults = $('<div id="search-results"></div>').appendTo('#ref-box');
	var resultContainer = $('<ul></ul>').appendTo(searchResults);

	// Holds the URL of the first result, in case the user presses enter
	var firstResult;

	function doSearch() {
		if (searchData == undefined) {
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
			var results = Fuzzy(text, searchData)

			// Limit number of results
			var max = results.length > 20 ? 20 : results.length;

			for (i = 0; i < max; i++) {
				var result = results[i][0];
				var highlight = results[i][4];
				var className = result.c;
				var memberName = result.m;
				// URL can be derived from the class and member name. Names
				// are encoded twice because some browsers try to be helpful
				// by decoding the URL automatically.
				var url = '/api/class/' + encodeURI(encodeURI(className)) + '.html' + (memberName ? '#member' + encodeURI(encodeURI(memberName)) : '');
				// Database also includes an icon index we can use for prettier results
				var icon = memberName ? 'api-member-icon' : 'api-class-icon';

				// Apply highlighting to either member or class name
				var hname = memberName ? memberName : className
				var c = ''
				var r = 0
				for (q = 0; q < hname.length; q++) {
					if (q == highlight[r]) {
						c += '<b>' + escapeHTML(hname[q]) + '</b>'
						r++
					} else {
						c += escapeHTML(hname[q])
					}
				}
				hname = c

				if (memberName == undefined) {
					className = hname
				} else {
					memberName = hname
					className = escapeHTML(className)
				}

				// Generate result element. The class and member name has
				// already been escaped by this point.
				var nitem = resultContainer.append(
					'<li><a href="' + escapeHTML(url) + '"><span class="' + escapeHTML(icon) + '" style="background-position:' + escapeHTML(result.i) * -16 + 'px center"></span>' + className + (memberName ? '.' + memberName : '') + '</a></li>'
				);

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
