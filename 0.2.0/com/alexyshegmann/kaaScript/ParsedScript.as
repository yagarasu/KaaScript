package com.alexyshegmann.kaaScript {
	
	import com.alexyshegmann.kaaScript.ParsedStatement;
	import com.alexyshegmann.kaaScript.parsing.*;
	
	public class ParsedScript {
		
		private var _stmts:Array = null;

		public function ParsedScript() {
			_stmts = new Array();
		}
		
		public function pushStatement(statement:ParsedStatement) {
			_stmts.push(statement);
		}
		
		public function getStatementAt(index:uint):ParsedStatement {
			if(index >= _stmts.length) {
				throw new Error("Index out of limits");
			}
			return _stmts[index];
		}
		
		public function get length():uint { return _stmts.length; }

	}
	
}
