function __sna(swfId) {

	var swf = document.getElementById(swfId);
	var wallPost;

	// init
	(function() {
		var script = document.createElement("script");
		script.src = "http://api.odnoklassniki.ru/js/fapi5.js";
		document.getElementsByTagName('head')[0].appendChild(script);

		function init() {
			if (!!window.FAPI) {
				var requestParameters = FAPI.Util.getRequestParameters();
				FAPI.init(requestParameters["api_server"], requestParameters["apiconnection"], function() {
					swf.__sna_completeInit();
				}, function() {});
			}
			else {
				setTimeout(init, 200);
			}
		}

		init();
	})();

	window.API_callback = function(method, result, data) {
//		console.log(method, result, data);
		var success = result == "ok";
		try {
			switch (method) {
				case "showPayment":
					swf.__sna_payment(success);
					break;
				case "showNotification":
					swf.__sna_friendsRequest(success, data);
					break;
				case "showConfirmation":
					if (wallPost) {
						if (success) {
							FAPI.Client.call(wallPost, function(status, data, error) { swf.__sna_makeWallPost(!error); }, data);
						}
						else {
							swf.__sna_makeWallPost(false);
						}
						wallPost = null;
					}
					break;
			}
		}
		catch (e) {
			if (window.console) {
				window.console.error(e);
			}
		}
	};

	window.__sna_makeWallPost = function(message) {
		wallPost = {method: "stream.publish", message: message};
		FAPI.UI.showConfirmation("stream.publish", message, FAPI.Client.calcSignature(wallPost));
	};

	window.__sna_api = function(method, params, callbackId) {
		try {
			params.method = method;
			FAPI.Client.call(params, function(success, data) {
				if (success == "ok") {
					swf.__sna_api(callbackId, data);
				}
			});
		}
		catch (e) {
			if (window.console) {
				window.console.error(e);
			}
		}
	};
}