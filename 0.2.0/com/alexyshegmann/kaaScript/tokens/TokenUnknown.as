package com.alexyshegmann.kaaScript.tokens {

	import com.alexyshegmann.kaaScript.tokens.Token;

	public class TokenUnknown extends Token {

		/**
		 * Se mantiene una clase separada para TokenUnknown para mantener la coherencia del encapsulamiento.
		 **/

		public function TokenUnknown(code:String, line:uint, position:uint) {
			super(code, line, position);
		}
		
		override public function toString():String {
			return  "[Unknown Token line="+_line+" position="+_position+" code=\""+_code+"\"]";
		}
		
		override public function tokenCode():String {
			return "T_UNK";
		}

	}
	
}
