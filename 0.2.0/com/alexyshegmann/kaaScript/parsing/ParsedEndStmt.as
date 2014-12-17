package com.alexyshegmann.kaaScript.parsing {
	
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	import com.alexyshegmann.kaaScript.ParsedStatement;
	
	public class ParsedEndStmt extends ParsedStatement {
		
		private var _endVal:* = null;

		public function ParsedEndStmt(tokStmt:TokenizedStatement, endValue:*=null) {
			super(tokStmt);
			_endVal = endValue;
		}
		
		public function get endValue():String { return _endVal; }

	}
	
}
