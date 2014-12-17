package com.alexyshegmann.kaaScript.tokens {
	
	import com.alexyshegmann.kaaScript.tokens.Token;
	
	public class TokenKeyword extends Token {
		
		private var _keyword:String = "";

		public function TokenKeyword(code:String, line:uint, position:uint, keyword:String) {
			super(code, line, position);
			_keyword = keyword;
		}
		
		public function get keyword():String { return _keyword; }
		
		override public function toString():String {
			return "[Keyword Token line="+_line+" position="+_position+" keyword=\""+_keyword+"\" code=\""+_code+"\"]";
		}
		
		override public function tokenCode():String {
			return "T_"+_keyword.toUpperCase();
		}

	}
	
}
