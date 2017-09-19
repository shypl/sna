package org.shypl.sna {
	import ru.capjack.flacy.core.utils.Strings;
	
	public class SnUser {
		private var _id:String;
		private var _firstName:String;
		private var _lastName:String;
		private var _avatar:String;
		private var _gender:SnUserGender;
		
		public function SnUser(id:String, firstName:String, lastName:String, avatar:String, gender:SnUserGender) {
			_id = id;
			_firstName = firstName;
			_lastName = lastName;
			_avatar = avatar;
			_gender = gender;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get firstName():String {
			return _firstName;
		}
		
		public function get lastName():String {
			return _lastName;
		}
		
		public function get name():String {
			return Strings.trim(_firstName + " " + _lastName);
		}
		
		public function get avatar():String {
			return _avatar;
		}
		
		public function get gender():SnUserGender {
			return _gender;
		}
	}
}
