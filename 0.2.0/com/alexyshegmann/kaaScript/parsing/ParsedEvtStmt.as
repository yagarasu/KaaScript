package com.alexyshegmann.kaaScript.parsing {
	
	import com.alexyshegmann.kaaScript.ParsedStatement;
	import com.alexyshegmann.kaaScript.parsing.ParsedExpr;
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	
	public class ParsedEvtStmt extends ParsedStatement {
		
		private var _varList:Array = null;

		public function ParsedEvtStmt(tokStmt:TokenizedStatement) {
			super(tokStmt);
			_varList = new Array();
		}
		
		public function pushEvtExp(expr:ParsedExpr):void {
			_varList.push(expr);
		}
		
		public function get varList():Array { return _varList; }

	}
	
}
