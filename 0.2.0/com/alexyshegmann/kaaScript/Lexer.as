package com.alexyshegmann.kaaScript {
	
	import com.alexyshegmann.kaaScript.tokens.*;
	import com.alexyshegmann.kaaScript.TokenizedScript;
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	import com.alexyshegmann.kaaScript.events.LexerEvent;
	import flash.events.EventDispatcher;
	
	public class Lexer extends EventDispatcher {
		
		public static const LEXER_STATE_ZERO:uint = 0;
		public static const LEXER_STATE_LABEL:uint = 1;
		public static const LEXER_STATE_VARIABLE:uint = 2;
		public static const LEXER_STATE_STRLITERAL:uint = 3;
		public static const LEXER_STATE_NUMLITERAL:uint = 4;
		public static const LEXER_STATE_KEYWORD:uint = 5;
		public static const LEXER_STATE_UNKNOWN:uint = 6;
		
		public static const LEXER_ACCEPTED_KEYWORDS:Array = new Array(
			"SET", 
			"ADD", "SUB", "MUL", "DIV", "MOD", "EXP", 
			"AND", "OR", "XOR", "NOT",
			"JMP", "JEQ", "JNE", "JLT", "JGT", "JLE", "JGE",
			"JTR", "JFA", 
			"PRT", "EVT", "RE", "WR",
			"END"
		);
		
		private var _rawScript:String = "";
		private var _tokenizedScript:TokenizedScript = null;
		private var _hasErrors = false;
		
		private var _state = LEXER_STATE_ZERO;
		private var _cursor:uint = 0;
		private var _cLine:uint = 1;
		private var _cPos:uint = 1;
		private var _cChar:String = "";
		private var _cWord:String = "";
		private var _cStat:TokenizedStatement = null;

		public function Lexer(rawScript:String="") {
			_rawScript = rawScript;
			tokenize();
		}
		
		public function get tokenizedScript():TokenizedScript { return _tokenizedScript; }
		public function get hasErrors():Boolean { return _hasErrors; }
		
		public function get script():String { return _rawScript; }
		public function set script(rawScript:String):void {
			_rawScript = rawScript;
			tokenize();
		}
		
		private function tokenize():void {
			_hasErrors = false;
			_tokenizedScript = new TokenizedScript();
			_cStat = new TokenizedStatement();
			//_rawScript = _rawScript.replace(/\t+/gim, " ");
			while(_cursor < _rawScript.length) {
				_cChar = _rawScript.charAt(_cursor);
				if(_cChar=="\n") {
					_cLine++;
					_cPos = 0;
				}
				_cPos++;
				switch(_state) {
					case LEXER_STATE_ZERO:
						if(/\s/.test(_cChar)) {
							_cursor++;
							break;
						}
						if(_cChar==";") {
							_cStat.appendToken(new TokenEndSt(";", _cLine, _cPos));
							pushStat();
							_cursor++;
							break;
						}
						if(_cChar==",") {
							_cStat.appendToken(new TokenComa(",", _cLine, _cPos));
							_cursor++;
							break;
						}
						if(_cChar==":") {
							_state = LEXER_STATE_LABEL;
							pushChar();
							_cursor++;
							break;
						}
						if(_cChar=="$") {
							_state = LEXER_STATE_VARIABLE;
							pushChar();
							_cursor++;
							break;
						}
						if(_cChar=="\"") {
							_state = LEXER_STATE_STRLITERAL;
							_cursor++;
							break;
						}
						if(/\d|\./.test(_cChar)) {
							_state = LEXER_STATE_NUMLITERAL;
							break;
						}
						if(/[A-Za-z]/.test(_cChar)) {
							_state = LEXER_STATE_KEYWORD;
							break;
						}
						_state = LEXER_STATE_UNKNOWN;
					break;
					case LEXER_STATE_LABEL: parseLabel(); break;
					case LEXER_STATE_VARIABLE: parseVariable(); break;
					case LEXER_STATE_STRLITERAL: parseStrLiteral(); break;
					case LEXER_STATE_NUMLITERAL: parseNumLiteral(); break;
					case LEXER_STATE_KEYWORD: parseKeyword(); break;
					case LEXER_STATE_UNKNOWN: parseUnknown(); break;
				}
			}
		}
		
		private function parseLabel():void {
			if(/([a-zA-Z0-9])/.test(_cChar)) {
				pushChar();
				_cursor++;
			} else {
				_cStat.appendToken(new TokenLabel(_cWord, _cLine, _cPos, _tokenizedScript.length, _cWord));
				_cWord = "";
				_state = LEXER_STATE_ZERO;
			}
		}
		private function parseVariable():void {
			if(/([a-zA-Z0-9])/.test(_cChar)) {
				pushChar();
				_cursor++;
			} else {
				_cStat.appendToken(new TokenVariable(_cWord, _cLine, _cPos, _cWord));
				_cWord = "";
				_state = LEXER_STATE_ZERO;
			}
		}
		private function parseStrLiteral():void {
			if(_cChar=="\""&&_cWord.substr(-1,1)!="\\") {
				_cStat.appendToken(new TokenStrLiteral("\""+_cWord+"\"", _cLine, _cPos, _cWord.replace(/\\\"/gim, "\"")));
				_cWord = "";
				_state = LEXER_STATE_ZERO;
				_cursor++;
			} else {
				pushChar();
				_cursor++;
			}
		}
		private function parseNumLiteral():void {
			if(/\d|\./.test(_cChar)) {
				pushChar();
				_cursor++;
			} else {
				_cStat.appendToken(new TokenNumLiteral(_cWord, _cLine, _cPos, Number(_cWord)));
				_cWord = "";
				_state = LEXER_STATE_ZERO;
			}
		}
		private function parseKeyword():void {
			if(/[A-Za-z]/.test(_cChar)) {
				pushChar();
				_cursor++;
			} else {
				if(_cWord == "TRUE") {
					_cStat.appendToken(new TokenBoolLiteral(_cWord, _cLine, _cPos, true));
				} else if(_cWord == "FALSE") {
					_cStat.appendToken(new TokenBoolLiteral(_cWord, _cLine, _cPos, false));
				} else {
					if(LEXER_ACCEPTED_KEYWORDS.indexOf(_cWord) !== -1) {
						_cStat.appendToken(new TokenKeyword(_cWord, _cLine, _cPos, _cWord));
					} else {
						_cStat.appendToken(new TokenUnknown(_cWord, _cLine, _cPos));
						_hasErrors = true;
						dispatchEvent(new LexerEvent(LexerEvent.UNKNOWN_TOKEN, _cLine, _cPos, _cWord));
					}
				}
				_cWord = "";
				_state = LEXER_STATE_ZERO;
			}
		}
		private function parseUnknown():void {
			if(!(/\s|,|;/.test(_cChar))) {
				pushChar();
				_cursor++;
			} else {
				_cStat.appendToken(new TokenUnknown(_cWord, _cLine, _cPos));
				_hasErrors = true;
				dispatchEvent(new LexerEvent(LexerEvent.UNKNOWN_TOKEN, _cLine, _cPos, _cWord));
				_cWord = "";
				_state = LEXER_STATE_ZERO;
			}
		}
		
		private function pushChar():void {
			_cWord += _cChar;
		}

		private function pushStat():void {
			_tokenizedScript.pushStatement(_cStat);
			_cStat = new TokenizedStatement();
		}

	}
	
}
