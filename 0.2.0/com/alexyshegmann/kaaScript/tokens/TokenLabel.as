package com.alexyshegmann.kaaScript.tokens {

	import com.alexyshegmann.kaaScript.tokens.Token;

	public class TokenLabel extends Token {
		
		private var _address:uint = 0;
		private var _ident:String = "";

		public function TokenLabel(code:String, line:uint, position:uint, address:uint, identifier:String) {
			super(code, line, position);
			_address = address;
			_ident = identifier;
		}
		
		public function get address():uint { return _address; }
		public function get identifier():String { return _ident; }
		
		override public function toString():String {
			return "[Label Token line="+_line+" position="+_position+" address="+_address+" identifier=\""+_ident+"\" code=\""+_code+"\"]";
		}
		
		override public function tokenCode():String {
			return "T_LABEL";
		}

	}
	
}
