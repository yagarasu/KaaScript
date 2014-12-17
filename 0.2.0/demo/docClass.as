package demo {
	
	import flash.display.MovieClip;
	import demo.Tile;
	import flash.events.MouseEvent;
	import com.alexyshegmann.kaaScript.VirtualMachine;
	import com.alexyshegmann.kaaScript.events.VMEvent;
	
	public class docClass extends MovieClip {
		
		private var tiles:Array = null;
		private var vm:VirtualMachine = null;
		
		public function docClass() {
			tiles = new Array();
			var t:Tile = null;
			for(var i = 1; i <= 10; i++) {
				for(var j = 1; j <= 5; j++) {
					t = new Tile();
					t.x = i * 55;
					t.y = j * 55;
					t.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
					addChild(t);
					tiles.push(t);
				}
			}
		}
		
		private function prt(e:VMEvent):void {
			trace("> "+e.params.fString);
		}
		private function evt(e:VMEvent):void {
			trace("Evento disparado> "+e.params.args);
		}
		private function onVMEvent(e:VMEvent):void {
			trace(e);
		}
		
		private function onClick(e:MouseEvent):void {
			if(e.target is Tile) {
				setChildIndex((e.target as Tile), numChildren-1);
			}
			if(!e.altKey&& e.target is Tile) {
				vm = new VirtualMachine();
				vm.addEventListener(VMEvent.PRINT, prt, false, 0, true);
				vm.addEventListener(VMEvent.SCRIPT_EVENT, evt, false, 0, true);
				vm.addEventListener(VMEvent.EXEC_START, onVMEvent, false, 0, true);
				vm.addEventListener(VMEvent.EXEC_END, onVMEvent, false, 0, true);
				vm.addEventListener(VMEvent.PARSE_START, onVMEvent, false, 0, true);
				vm.addEventListener(VMEvent.PARSE_END, onVMEvent, false, 0, true);
				vm.addEventListener(VMEvent.RUNTIME_ERROR, onVMEvent, false, 0, true);
				vm.script = (e.target as Tile).script;
				vm.run();
			}
		}
	}
	
}
