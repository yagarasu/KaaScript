package com.alexyshegmann.kaaScript.tokens {
	
	import com.alexyshegmann.kaaScript.tokens.TokenLiteral;
	
	public class TokenStrLiteral extends TokenLiteral {
		
		private var _value:String = "";

		public function TokenStrLiteral(code:String, line:uint, position:uint, literalValue:String) {
			super(code, line, position);
			_value = literalValue;
		}
		
		override public function get literalValue():* { return _value; }
		
		override public function toString():String {
			return "[String Literal Token line="+_line+" position="+_position+" value=\""+_value+"\" code=\""+_code+"\"]";
		}
		
		override public function tokenCode():String {
			return "T_STR";
		}

	}
	
}
