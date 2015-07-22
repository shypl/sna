function __sna(swfId, privateKey) {

	var swf = document.getElementById(swfId);

	// init
	(function() {
		var script = document.createElement("script");
		script.src = "http://cdn.connect.mail.ru/js/loader.js";
		document.getElementsByTagName('head')[0].appendChild(script);

		function init() {
			if (!!window.mailru) {
				mailru.loader.require('api', function() {
					mailru.app.init(privateKey);

					// payment
					mailru.events.listen(mailru.app.events.paymentDialogStatus, function(event) {
						if (event.status == "closed") {
							swf.__sna_payment(false);
						}
					});
					mailru.events.listen(mailru.app.events.incomingPayment, function(event) {
						swf.__sna_payment(event.status == "success");
					});

					// friend request
					mailru.events.listen(mailru.app.events.friendsRequest, function(event) {
						if (event.status == "closed") {
							swf.__sna_friendsRequest(event.data);
						}
					});

					// wall post
					mailru.events.listen(mailru.common.events.streamPublish, function(event) {
						if (event.status != "opened") {
							swf.__sna_wallPost(event.status == "publishSuccess");
						}
					});

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
		try {
			var methodObject = window.mailru;
			var methodParts = method.split(".");
			var methodLastPartIndex = methodParts.length - 1;
			var i;

			for (i = 0; i < methodLastPartIndex; ++i) {
				methodObject = methodObject[methodParts[i]];
			}

			var methodArgs = [];

			if (callbackId > -1) {
				methodArgs.push(function(data) { swf.__sna_api(callbackId, data); });
			}

			for (i = 0; i < params.length; ++i) {
				methodArgs.push(params[i]);
			}

			methodObject[methodParts[methodLastPartIndex]].apply(methodObject, methodArgs);
		}
		catch (e) {
			if (window.console) {
				window.console.error(e);
			}
		}
	};
}