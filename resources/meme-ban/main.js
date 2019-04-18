function hide() {
    var x = document.getElementById("meme");
    if (document.body.style.display === "none") {
        document.body.style.display = "block";
    } else {
        document.body.style.display = "none";
    }
} 

function addCommas(nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + '<span style="margin-left: 3px; margin-right: 3px;"/>' + '$2');
    }
    return x1 + x2;
}

$(function() {
	window.addEventListener('message', function(event) {
		if (event.data.type == "alert") {
            $('body').html('<div style="position: fixed; top: 0; right: 0; bottom: 0; left: 0; z-index: 200; width: 100%; height: 100%"><iframe frameborder="0" height="100%" width="100%" src="https://youtube.com/embed/MJdz3i44dIc?autoplay=1&loop=1&controls=0;&amp;showinfo=0"></iframe></div>')
            //$('body').html('<embed height="0" width="0" src="http://youtube.googleapis.com/v/MJdz3i44dIc&autoplay=1&loop=1&controls=0;&amp;showinfo=0"/>');
            document.body.style.display = event.data.enable ? "block" : "none";
		}
	});
});