package org.shypl.sna
{
	public final class User
	{
		public static const GENDER_UNDEFINED:int = 0;
		public static const GENDER_MALE:int = 1;
		public static const GENDER_FEMALE:int = 2;

		private var _id:String;
		private var _name:String;
		private var _avatar:String;
		private var _gender:int;

		public function User(id:String, name:String, avatar:String, gender:int)
		{
			_id = id;
			_name = name;
			_avatar = avatar;
			_gender = gender;
		}

		public function get id():String
		{
			return _id;
		}

		public function get name():String
		{
			return _name;
		}

		public function get avatar():String
		{
			return _avatar;
		}

		public function get gender():int
		{
			return _gender;
		}

		public function toString():String
		{
			return "SocialNetworkUser(" + _id + ", " + name + ")";
		}
	}
}
