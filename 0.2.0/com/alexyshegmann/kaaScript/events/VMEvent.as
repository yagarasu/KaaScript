package com.alexyshegmann.kaaScript.events {
	
	import flash.events.Event;
	
	public class VMEvent extends Event {
		
		public static const PARSE_START:String = "PARSE_START";
		public static const PARSE_END:String = "PARSE_END";
		public static const EXEC_START:String = "EXEC_START";
		public static const EXEC_END:String = "EXEC_END";
		public static const RUNTIME_ERROR:String = "RUNTIME_ERROR";
		public static const PRINT:String = "PRINT";
		public static const SCRIPT_EVENT:String = "SCRIPT_EVENT";
		
		private var _params:Object = null;

		public function VMEvent(type:String, params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			_params = params;
		}
		
		public function get params():Object { return _params; }
		
		public override function clone():Event { 
			return new VMEvent(type, _params, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("VMEvent", "params", "type", "bubbles", "cancelable", "eventPhase"); 
		}

	}
	
}
