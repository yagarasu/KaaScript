package com.alexyshegmann.kaaScript {
	
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	
	public class ParsedStatement {

		private var _tokenStmt:TokenizedStatement = null;

		public function ParsedStatement(tokenizedStatement:TokenizedStatement) {
			_tokenStmt = tokenizedStatement;
		}
		
		public function get tokenizedStatement():TokenizedStatement {
			return _tokenStmt;
		}
		
		public function toString():String {
			return  "[Parsed Statement]";
		}

	}
	
}
