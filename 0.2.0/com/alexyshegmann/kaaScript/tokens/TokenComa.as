package com.alexyshegmann.kaaScript.tokens {

	import com.alexyshegmann.kaaScript.tokens.Token;

	public class TokenComa extends Token {

		/**
		 * Se mantiene una clase separada para TokenComa para mantener la coherencia del encapsulamiento.
		 **/

		public function TokenComa(code:String, line:uint, position:uint) {
			super(code, line, position);
		}
		
		override public function toString():String {
			return  "[Coma Token line="+_line+" position="+_position+" code=\""+_code+"\"]";
		}
		
		override public function tokenCode():String {
			return "T_COMA";
		}

	}
	
}
