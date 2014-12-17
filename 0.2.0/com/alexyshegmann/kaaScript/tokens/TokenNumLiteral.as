package com.alexyshegmann.kaaScript.tokens {
	
	import com.alexyshegmann.kaaScript.tokens.TokenLiteral;
	
	public class TokenNumLiteral extends TokenLiteral {
		
		private var _value:Number = 0;

		public function TokenNumLiteral(code:String, line:uint, position:uint, literalValue:Number) {
			super(code, line, position);
			_value = literalValue;
		}
		
		override public function get literalValue():* { return _value; }
		
		override public function toString():String {
			return "[Numeric Literal Token line="+_line+" position="+_position+" value="+_value+" code=\""+_code+"\"]";
		}
		
		override public function tokenCode():String {
			return "T_NUM";
		}

	}
	
}
