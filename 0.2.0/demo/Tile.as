package demo {
	
	import flash.display.MovieClip;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	
	public class Tile extends MovieClip {
		
		public var script:String = ":Init;\nPRT \"Esta es una prueba.\";\nEND;";
		private var scredit:MovieClip = null;
		private var scredit_txt:TextField = null;

		public function Tile() {
			var g:Graphics = this.graphics;
			g.beginFill(0x0099cc);
			g.drawRoundRect(0,0,50,50,10,10);
			addEventListener(MouseEvent.ROLL_OVER, onRollover, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onRollout, false, 0, true);
			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
			
			scredit = new MovieClip();
			scredit.x = 10;
			scredit.y = 25;
			
			scredit_txt = new TextField();
			scredit_txt.width = 200;
			scredit_txt.height = 80;
			scredit_txt.type = TextFieldType.INPUT;
			scredit_txt.multiline = true;
			scredit_txt.autoSize = TextFieldAutoSize.NONE;
			scredit_txt.defaultTextFormat = new TextFormat("Courier New", 12, 0x000000);
			scredit_txt.background = true;
			scredit_txt.border = true;
			scredit_txt.text = script;
			scredit.addChild(scredit_txt);
			
			scredit.visible = false;
			addChild(scredit);
		}
		
		private function onRollover(e:MouseEvent):void {
			this.alpha = 0.5;
		}
		private function onRollout(e:MouseEvent):void {
			this.alpha = 1;
		}
		private function onClick(e:MouseEvent):void {
			if(e.altKey) {
				scredit.visible = true;
			}
		}
		private function onAdded(e:Event):void {
			stage.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
			removeEventListener(Event.ADDED_TO_STAGE, onAdded, false);
		}
		private function onKey(e:KeyboardEvent):void {
			if(e.keyCode==27) {
				script = scredit_txt.text;
				scredit.visible = false;
			}
		}

	}
	
}
