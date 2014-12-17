package  {
	
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import flash.net.FileReference;
	import com.alexyshegmann.kaaScript.VirtualMachine;
	import com.alexyshegmann.kaaScript.events.VMEvent;
	import com.alexyshegmann.kaaScript.events.LexerEvent;
	import com.alexyshegmann.kaaScript.events.ParserEvent;
	import com.alexyshegmann.kaaScript.*;
	import com.alexyshegmann.kaaScript.parsing.ParsedExpr;
	import com.alexyshegmann.kaaScript.virtualmachine.VMContext;
	
	public class docClass extends MovieClip {
		
		private var vm:VirtualMachine = null;
		
		public function docClass() {
			var scr:String = (<![CDATA[
									   
			:init;
				PRT "For loop";
				SET $external, "FOO";
				PRT "PredefContext: ", $predefinida;
				SET $i, 0;
				SET $lmt, 20;
				SET $stp, 2;
				:forLoop;
					PRT "$i=", $i;
					ADD $i, $i, $stp;
					JEQ $i, 10, :is10;
					JLE $i, $lmt, :forLoop;
				END;
				
			:is10;
				EVT "IS10";
				JMP :forLoop;
									   
			]]>).toString();
			
			vm = new VirtualMachine();
			vm.addEventListener(LexerEvent.UNKNOWN_TOKEN, onLexerError, false, 0, true);
			vm.addEventListener(ParserEvent.UNKNOWN_STATEMENT, onParserError, false, 0, true);
			vm.addEventListener(VMEvent.PARSE_START, onVMEvent, false, 0, true);
			vm.addEventListener(VMEvent.PARSE_END, onVMEvent, false, 0, true);
			vm.addEventListener(VMEvent.EXEC_START, onVMEvent, false, 0, true);
			vm.addEventListener(VMEvent.EXEC_END, onVMEvent, false, 0, true);
			vm.addEventListener(VMEvent.RUNTIME_ERROR, onRuntimeError, false, 0, true);
			vm.addEventListener(VMEvent.PRINT, onPrint, false, 0, true);
			vm.addEventListener(VMEvent.SCRIPT_EVENT, onEvt, false, 0, true);
			vm.script = scr;
			vm.predefinedContext.variableTable.setVar("$predefinida", new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_STRLIT, "Estoy predefinida"));
			vm.run();
			
		}
		
		private function onLexerError(e:LexerEvent):void {
			trace("Se encontró un error léxico en la línea "+e.line+" en el caracter "+e.position+": "+e.word);
		}
		private function onParserError(e:ParserEvent):void {
			trace("Se encontró un error de sintaxis en la línea "+e.line+" en el caracter "+e.position+": "+e.word);
		}
		private function onVMEvent(e:VMEvent):void {
			trace("VMEvent: " + e);
		}
		private function onRuntimeError(e:VMEvent):void {
			trace("Hubo un error en tiempo de ejecución: #"+e.params.code+"> "+e.params.message);
		}
		private function onPrint(e:VMEvent):void {
			trace("> "+e.params.fString);
		}
		private function onEvt(e:VMEvent):void {
			trace("EVENTO!> "+e.params.args);
			trace("externando variable $external: " + (vm.context.variableTable.getVar("$external") as ParsedExpr).value);
			if((e.params.args as Array)[0]=="IS10") {
				vm.overrideVariable("$i", new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, 16));
			}
		}
	}
	
}
