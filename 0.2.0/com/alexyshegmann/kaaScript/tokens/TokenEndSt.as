package com.alexyshegmann.kaaScript.tokens {

	import com.alexyshegmann.kaaScript.tokens.Token;

	public class TokenEndSt extends Token {

		/**
		 * Se mantiene una clase separada para TokenEndSt para mantener la coherencia del encapsulamiento.
		 **/

		public function TokenEndSt(code:String, line:uint, position:uint) {
			super(code, line, position);
		}
		
		override public function toString():String {
			return  "[EndSt Token line="+_line+" position="+_position+" code=\""+_code+"\"]";
		}
		
		override public function tokenCode():String {
			return "T_ENDST";
		}

	}
	
}
