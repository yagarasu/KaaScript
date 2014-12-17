package com.alexyshegmann.kaaScript.parsing {
	
	import com.alexyshegmann.kaaScript.ParsedStatement;
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	
	public class ParsedLabelStmt extends ParsedStatement {
		
		private var _ident:String = "";
		private var _address:uint = 0;

		public function ParsedLabelStmt(tokStmt:TokenizedStatement, identifier:String, address:uint) {
			super(tokStmt);
			_ident = identifier;
			_address = address;
		}
		
		public function get identifier():String { return _ident; }
		public function get address():uint { return _address; }

	}
	
}
