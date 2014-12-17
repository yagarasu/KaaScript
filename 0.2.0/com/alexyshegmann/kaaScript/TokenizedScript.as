package com.alexyshegmann.kaaScript {
	
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	
	public class TokenizedScript {
		
		private var _tokenized:Array = null;

		public function TokenizedScript() {
			_tokenized = new Array();
		}
		
		public function pushStatement(tokenizedStatement:TokenizedStatement):void {
			_tokenized.push(tokenizedStatement);
		}
		
		public function getStatementAt(index:uint):TokenizedStatement {
			if(index >= _tokenized.length) {
				throw new Error("Index out of limits");
			}
			return _tokenized[index];
		}
		
		public function get length():uint { return _tokenized.length; }
		
		public function toString():String {
			return "[Tokenized Script length="+_tokenized.length+"]";
		}
		
		public function tokenizedString():String {
			return _tokenized.join("\n");
		}

	}
	
}
