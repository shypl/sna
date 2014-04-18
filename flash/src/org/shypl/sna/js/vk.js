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

					VK.addCallback("onOrderSuccess", function() { swf.__sna_payment(true); });
					VK.addCallback("onOrderCancel", function() { swf.__sna_payment(false, 0); });
					VK.addCallback("onOrderFail", function(errorCode) { swf.__sna_payment(false, errorCode); });

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
			swf.__sna_api(callbackId, data);
		});
	};

	// client
	window.__sna_client = function(method, params) {
		var args = [method];
		for (var i = 0; i < params.length; ++i) {
			args.push(params[i]);
		}
		VK.callMethod.apply(args);
	};
}