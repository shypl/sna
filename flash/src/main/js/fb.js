function __sna(swfId, appId) {
	
	var swf = document.getElementById(swfId);
	
	// init
	(function() {
		var script = document.createElement("script");
		script.src = "//connect.facebook.net/en_US/sdk.js";
		document.getElementsByTagName('head')[0].appendChild(script);
		
		window.fbAsyncInit = function () {
			FB.init({
				appId: appId,
				cookie: true,
				status: true,
				version: 'v2.8'
			});
			
			FB.getLoginStatus(onLogin);
		};
		
		function onLogin(response) {
			if (response.status == 'connected') {
				swf.__sna_completeInit();
			} else {
				FB.login(onLogin);
			}
		}
	})();
	
	window.__sna_api = function(path, method, params, callbackId) {
		try {
			FB.api("/" + path, method, params, function(data) {
				swf.__sna_api(callbackId, data);
			});
		}
		catch (e) {
			if (window.console) {
				window.console.error(e);
			}
		}
	};
	
	window.__sna_ui = function (params, callbackId) {
		try {
			FB.ui(params, function(data) {
				swf.__sna_ui(callbackId, data);
			});
		}
		catch (e) {
			if (window.console) {
				window.console.error(e);
			}
		}
	};
	
}