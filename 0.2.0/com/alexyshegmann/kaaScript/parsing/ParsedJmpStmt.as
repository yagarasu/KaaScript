package com.alexyshegmann.kaaScript.parsing {
	
	import com.alexyshegmann.kaaScript.ParsedStatement;
	import com.alexyshegmann.kaaScript.parsing.ParsedExpr;
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	
	public class ParsedJmpStmt extends ParsedStatement {
		
		private var _type:String = "";
		private var _opA:ParsedExpr = null;
		private var _opB:ParsedExpr = null;
		private var _goTo:String = "";

		public function ParsedJmpStmt(tokStmt:TokenizedStatement, type:String, goTo:String, opA:ParsedExpr, opB:ParsedExpr) {
			super(tokStmt);
			_type = type;
			_opA = opA;
			_opB = opB;
			_goTo = goTo;
		}

		public function get type():String { return _type; }
		public function get opA():ParsedExpr { return _opA; }
		public function get opB():ParsedExpr { return _opB; }
		public function get goTo():String { return _goTo; }

	}
	
}
