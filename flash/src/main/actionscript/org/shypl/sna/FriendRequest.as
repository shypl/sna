package org.shypl.sna {
	public class FriendRequest {
		private var _message:String;
		private var _image:String;
		
		public function FriendRequest(message:String = null, image:String = null) {
			_message = message;
			_image = image;
		}
		
		public function get message():String {
			return _message;
		}
		
		public function get image():String {
			return _image;
		}
	}
}
