package com.alexyshegmann.kaaScript.tokens {
	
	public class Token {
		
		protected var _code:String = "";
		protected var _line:uint = 0;
		protected var _position:uint = 0;

		public function Token(code:String, line:uint, position:uint) {
			_code = code;
			_line = line;
			_position = position;
		}
		
		public function get code():String { return _code; }
		public function get line():uint { return _line; }
		public function get position():uint { return _position; }
		
		public function toString():String {
			return "[Token line="+_line+" position="+_position+" code=\""+_code+"\"]";
		}
		
		public function tokenCode():String {
			return "TOKEN";
		}

	}
	
}
