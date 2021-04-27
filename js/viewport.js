(function (doc, win) {
	var docEl = doc.documentElement,
	resizeEvt = 'orientationchange' in window ? 'orientationchange' : 'resize',
			recalc = function () {
		var clientWidth = docEl.clientWidth;
		if (!clientWidth) return;
		var fontSize = 20 * (clientWidth / 375);
		if(fontSize > 40) {
			fontSize = 40;
		}
		if(fontSize < 10) {
			fontSize = 10;
		}
		docEl.style.fontSize = fontSize + 'px';
	};
	if (!doc.addEventListener) return;
	win.addEventListener(resizeEvt, recalc, false);
	doc.addEventListener('DOMContentLoaded', recalc, false);
})(document, window);