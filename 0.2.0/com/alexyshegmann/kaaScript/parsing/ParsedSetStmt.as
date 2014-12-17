package com.alexyshegmann.kaaScript.parsing {
	
	import com.alexyshegmann.kaaScript.ParsedStatement;
	import com.alexyshegmann.kaaScript.parsing.ParsedExpr;
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	
	public class ParsedSetStmt extends ParsedStatement {
		
		private var _ident:String = "";
		private var _val:ParsedExpr = null;

		public function ParsedSetStmt(tokStmt:TokenizedStatement, identifier:String, value:ParsedExpr) {
			super(tokStmt);
			_ident = identifier;
			_val = value;
		}
		
		public function get identifier():String { return _ident; }
		public function get value():ParsedExpr { return _val; }

	}
	
}
