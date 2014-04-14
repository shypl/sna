function __sna(swfId) {

	var swf = document.getElementById(swfId);

	// init
	(function() {
		var script = document.createElement("script");
		script.src = "//vk.com/js/api/xd_connection.js?2";
		document.getElementsByTagName('head')[0].appendChild(script);

		function init() {
			if (!!window.VK) {
				VK.init(function() {
					swf.__sna_inited();
				});
			}
			else {
				setTimeout(init, 200);
			}
		}

		init();
	})();

	// api
	window.__sna_api = function(method, params, callbackId) {
		VK.api(method, params, function(data) {
			swf.__sna_api_callback(callbackId, data);
		});
	};
}