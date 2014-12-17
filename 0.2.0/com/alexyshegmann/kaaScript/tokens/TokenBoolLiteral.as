package com.alexyshegmann.kaaScript.tokens {
	
	import com.alexyshegmann.kaaScript.tokens.TokenLiteral;
	
	public class TokenBoolLiteral extends TokenLiteral {
		
		private var _value:Boolean = false;

		public function TokenBoolLiteral(code:String, line:uint, position:uint, literalValue:Boolean) {
			super(code, line, position);
			_value = literalValue;
		}
		
		override public function get literalValue():* { return _value; }
		
		override public function toString():String {
			return "[Boolean Literal Token line="+_line+" position="+_position+" value="+_value+" code=\""+_code+"\"]";
		}
		
		override public function tokenCode():String {
			return "T_BOOL";
		}

	}
	
}
