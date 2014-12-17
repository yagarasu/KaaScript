package com.alexyshegmann.kaaScript.parsing {
	
	import com.alexyshegmann.kaaScript.ParsedStatement;
	import com.alexyshegmann.kaaScript.parsing.ParsedExpr;
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	
	public class ParsedPrtStmt extends ParsedStatement {
		
		private var _prtList:Array = null;

		public function ParsedPrtStmt(tokStmt:TokenizedStatement) {
			super(tokStmt);
			_prtList = new Array();
		}
		
		public function pushPrtExp(expr:ParsedExpr):void {
			_prtList.push(expr);
		}
		
		public function get prtList():Array { return _prtList; }

	}
	
}
