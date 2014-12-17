package com.alexyshegmann.kaaScript {
	
	import com.alexyshegmann.kaaScript.tokens.Token;
	
	public class TokenizedStatement {
		
		public static const TOKENIZED_STMT_TYPE_ZERO:uint = 0;
		public static const TOKENIZED_STMT_TYPE_LABEL:uint = 1;
		public static const TOKENIZED_STMT_TYPE_SET:uint = 2;
		public static const TOKENIZED_STMT_TYPE_END:uint = 3;
		
		private var _tokenized:Array = null;
		public var type:uint = TOKENIZED_STMT_TYPE_ZERO;

		public function TokenizedStatement() {
			_tokenized = new Array();
		}
		
		public function appendToken(token:Token):void {
			_tokenized.push(token);
		}
		
		public function getTokenAt(index:uint):Token {
			if(index >= _tokenized.length) {
				throw new Error("Index out of limits");
			}
			return _tokenized[index];
		}
		
		public function get length():uint { return _tokenized.length; }
		
		public function toString():String {
			return "[Tokenized Statement length="+_tokenized.length+"]";
		}
		
		public function tokenizedString():String {
			var retVal:Array = new Array();
			for(var idx in _tokenized) {
				retVal.push(_tokenized[idx].tokenCode());
			}
			return retVal.join(" ");
		}

	}
	
}
