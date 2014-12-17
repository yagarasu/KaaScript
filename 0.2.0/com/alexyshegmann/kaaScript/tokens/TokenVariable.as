package com.alexyshegmann.kaaScript.tokens {
	
	import com.alexyshegmann.kaaScript.tokens.Token;
	
	public class TokenVariable extends Token {
		
		private var _ident:String

		public function TokenVariable(code:String, line:uint, position:uint, identifier:String) {
			super(code, line, position);
			_ident = identifier;
		}
		
		public function get identifier():String { return _ident; }
		
		override public function toString():String {
			return "[Variable Token line="+_line+" position="+_position+" identifier=\""+_ident+"\" code=\""+_code+"\"]";
		}
		
		override public function tokenCode():String {
			return "T_VAR";
		}

	}
	
}
