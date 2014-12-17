package com.alexyshegmann.kaaScript.tokens {
	
	import com.alexyshegmann.kaaScript.tokens.Token;
	
	public class TokenLiteral extends Token {
		
		/**
		 * Se mantiene la clase Token Literal por si es necesario implementar métodos en común con TokenStrLiteral, TokenNumLiteral, TokenBoolLiteral y lo que pueda surgir.
		 **/

		public function TokenLiteral(code:String, line:uint, position:uint) {
			super(code, line, position);
		}
		
		override public function tokenCode():String {
			return "T_LIT";
		}
		
		public function get literalValue():* { return null; }

	}
	
}
