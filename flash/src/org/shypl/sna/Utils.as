package org.shypl.sna {
	internal class Utils {
		public static function arrayToStringVector(data:Array):Vector.<String> {
			const list:Vector.<String> = new Vector.<String>(data.length, true);
			for (var i:int = 0; i < data.length; i++) {
				list[i] = data[i];
			}
			return list;
		}

	}
}
