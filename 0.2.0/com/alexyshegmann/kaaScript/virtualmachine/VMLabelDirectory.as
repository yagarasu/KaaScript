package com.alexyshegmann.kaaScript.virtualmachine {
	
	public class VMLabelDirectory {

		private var _dir:Object;

		public function VMLabelDirectory() {
			_dir = new Object();
		}
		
		public function setLabel(identifier:String, line:uint):void {
			_dir[identifier] = line;
		}
		
		public function getLineFor(identifier:String):int {
			if(_dir.hasOwnProperty(identifier)) {
				return _dir[identifier];
			} else {
				return -1;
			}
		}

	}
	
}
