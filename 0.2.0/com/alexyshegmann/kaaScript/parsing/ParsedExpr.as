package com.alexyshegmann.kaaScript.parsing {
	
	public class ParsedExpr {
		
		public static const PARSED_EXPR_TYPE_VAR:String = "EXPR_VAR";
		public static const PARSED_EXPR_TYPE_STRLIT:String = "EXPR_STRLIT";
		public static const PARSED_EXPR_TYPE_NUMLIT:String = "EXPR_NUMLIT";
		public static const PARSED_EXPR_TYPE_BOOLLIT:String = "EXPR_BOOLLIT";
		
		private var _type:String = "";
		private var _val:* = null;
		
		public function ParsedExpr(type:String, value:*=null) {
			_type = type;
			_val = value;
		}
		
		public function get type():String { return _type; }
		public function get value():String { return _val; }

	}
	
}
