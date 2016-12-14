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

					// payment
					VK.addCallback("onOrderSuccess", function() { swf.__sna_callbackClient("payment", true); });
					VK.addCallback("onOrderCancel", function() { swf.__sna_callbackClient("payment", false); });
					VK.addCallback("onOrderFail", function() { swf.__sna_callbackClient("payment", false); });

					// friends request
					VK.addCallback("onRequestSuccess", function() { swf.__sna_callbackClient("friendsRequest", true); });
					VK.addCallback("onRequestCancel", function() { swf.__sna_callbackClient("friendsRequest", false); });
					VK.addCallback("onRequestFail", function() { swf.__sna_callbackClient("friendsRequest", false); });

					swf.__sna_completeInit();
				}, function () {
					init();
				}, "5.60");
			}
			else {
				setTimeout(init, 200);
			}
		}

		init();
	})();

	// api
	window.__sna_api = function(method, params, callbackId) {
		try {
			VK.api(method, params, function(data) {
				swf.__sna_callbackApi(callbackId, data);
			});
		}
		catch (e) {
			if (window.console) {
				window.console.error(e);
			}
		}
	};

	// client
	window.__sna_client = function(method, params) {
		try {
			var args = [method];
			for (var i = 0; i < params.length; ++i) {
				args.push(params[i]);
			}
			VK.callMethod.apply(VK, args);
		}
		catch (e) {
			if (window.console) {
				window.console.error(e);
			}
		}
	};
}