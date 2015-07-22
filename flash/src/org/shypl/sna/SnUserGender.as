package org.shypl.sna {
	import org.shypl.common.lang.Enum;

	public final class SnUserGender extends Enum {
		public static const UNDEFINED:SnUserGender = new SnUserGender("UNDEFINED");
		public static const MALE:SnUserGender = new SnUserGender("MALE");
		public static const FEMALE:SnUserGender = new SnUserGender("FEMALE");

		public function SnUserGender(name:String) {
			super(name);
		}
	}
}
