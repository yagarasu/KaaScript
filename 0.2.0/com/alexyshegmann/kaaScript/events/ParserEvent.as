﻿package com.alexyshegmann.kaaScript.events {
	
	import flash.events.Event;
	
	public class ParserEvent extends Event {
		
		public static const UNKNOWN_STATEMENT:String = "UNKNOWN_STMT";
		
		private var _line:uint = 0;
		private var _pos:uint = 0;
		private var _word:String = "";

		public function ParserEvent(type:String, line:uint, position:uint, word:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			_line = line;
			_pos = position;
			_word = word;
		}
		
		public function get line():uint { return _line; }
		public function get position():uint { return _pos; }
		public function get word():String { return _word; }
		
		public override function clone():Event { 
			return new ParserEvent(type, _line, _pos, _word, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("LexerEvent", "line", "position", "word", "type", "bubbles", "cancelable", "eventPhase"); 
		}

	}
	
}
