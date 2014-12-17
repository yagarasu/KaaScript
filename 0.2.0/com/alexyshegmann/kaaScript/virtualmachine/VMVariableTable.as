package com.alexyshegmann.kaaScript.virtualmachine {
	
	public class VMVariableTable {
		
		private var _vars:Object;

		public function VMVariableTable() {
			_vars = new Object();
		}
		
		public function setVar(identifier:String, value:*):void {
			_vars[identifier] = value;
		}
		
		public function getVar(identifier:String):* {
			if(_vars.hasOwnProperty(identifier)) {
				return _vars[identifier];
			} else {
				return null;
			}
		}

	}
	
}
