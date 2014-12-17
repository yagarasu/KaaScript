package com.alexyshegmann.kaaScript {
	
	import flash.events.EventDispatcher;
	import com.alexyshegmann.kaaScript.Lexer;
	import com.alexyshegmann.kaaScript.Parser;
	import com.alexyshegmann.kaaScript.events.VMEvent;
	import com.alexyshegmann.kaaScript.events.LexerEvent;
	import com.alexyshegmann.kaaScript.events.ParserEvent;
	import com.alexyshegmann.kaaScript.parsing.*;
	import com.alexyshegmann.kaaScript.virtualmachine.*;
	
	public class VirtualMachine extends EventDispatcher {
		
		public static const RUNTIMEERR_VARNOTDEF:uint = 1;
		public static const RUNTIMEERR_BADVARTYPE:uint = 2;
		public static const RUNTIMEERR_DIVBYZERO:uint = 3;
		
		private var _script:String = "";
		private var _hasErrors:Boolean = false;
		private var _isRunning:Boolean = false;
		
		private var _cursor:uint = 0;
		private var _cStmt:ParsedStatement = null;
		
		private var lex:Lexer = null;
		private var par:Parser = null;
		private var _context:VMContext = null;
		public var predefinedContext:VMContext = null;

		public function VirtualMachine(script:String="", predefinedContext:VMContext=null) {
			_script = script;
			this.predefinedContext = (predefinedContext==null) ? new VMContext() : predefinedContext ;
			lex = new Lexer();
			lex.addEventListener(LexerEvent.UNKNOWN_TOKEN, on_lexerError, false, 0, true);
			par = new Parser();
			par.addEventListener(ParserEvent.UNKNOWN_STATEMENT, on_parserError, false, 0, true);
		}
		
		public function get isRunning():Boolean { return _isRunning; }
		public function get hasErrors():Boolean { return _hasErrors; }
		public function get cursor():uint { return _cursor; }
		
		public function get script():String { return _script; }
		public function set script(script:String):void {
			_script = script;
		}
		
		public function get context():VMContext { return _context; }
		
		public function overrideVariable(identifier:String, value:ParsedExpr) {
			_context.variableTable.setVar(identifier, value);
		}
		
		private function parse():void {
			_hasErrors = false;
			dispatchEvent(new VMEvent(VMEvent.PARSE_START));
			lex.script = _script;
			if(!_hasErrors) {
				par.tokenizedScript = lex.tokenizedScript;
			}
			dispatchEvent(new VMEvent(VMEvent.PARSE_END));
		}
		
		public function run():void {
			_context = predefinedContext;
			parse();
			if(!_hasErrors) {
				for(var i:uint = 0; i < par.parsedScript.length; i++) {
					if(par.parsedScript.getStatementAt(i) is ParsedLabelStmt) {
						_context.labelDir.setLabel((par.parsedScript.getStatementAt(i) as ParsedLabelStmt).identifier, (par.parsedScript.getStatementAt(i) as ParsedLabelStmt).address);
					}
				}
				dispatchEvent(new VMEvent(VMEvent.EXEC_START));
				_isRunning = true;
				while(_cursor < par.parsedScript.length && _isRunning) {
					_cStmt = par.parsedScript.getStatementAt(_cursor);
					execStmt(_cStmt);
				}
				_isRunning = false;
				dispatchEvent(new VMEvent(VMEvent.EXEC_END));
			}
		}
		
		public function execStmt(statement:ParsedStatement):void {
			if(statement is ParsedEndStmt) {
				_isRunning = false;
				return;
			}
			if(statement is ParsedSetStmt) {
				execSetStatement((statement as ParsedSetStmt));
				_cursor++;
				return;
			}
			if(statement is ParsedPrtStmt) {
				execPrtStatement((statement as ParsedPrtStmt));
				_cursor++;
				return;
			}
			if(statement is ParsedOpStmt) {
				execOpStatement((statement as ParsedOpStmt));
				_cursor++;
				return;
			}
			if(statement is ParsedJmpStmt) {
				execJmpStatement((statement as ParsedJmpStmt));
				return;
			}
			if(statement is ParsedEvtStmt) {
				execEvtStatement((statement as ParsedEvtStmt));
				_cursor++;
				return;
			}
			_cursor++;
		}
		
		private function execSetStatement(s:ParsedSetStmt):void {
			if(s.value.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) {
				var varVal:* = _context.variableTable.getVar(s.value.value);
				if(varVal != null) {
					_context.variableTable.setVar(s.identifier, varVal);
				} else {
					throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "Variable '"+s.value.value+"' not defined.");
					return;
				}
			} else {
				_context.variableTable.setVar(s.identifier, s.value);
			}
		}
		private function execPrtStatement(s:ParsedPrtStmt):void {
			var fStr:String = "";
			for(var i = 0; i < s.prtList.length; i++) {
				if((s.prtList[i] as ParsedExpr).type == ParsedExpr.PARSED_EXPR_TYPE_VAR) {
					var varVal:* = _context.variableTable.getVar((s.prtList[i] as ParsedExpr).value);
					if(varVal != null) {
						fStr += (varVal as ParsedExpr).value.toString();
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "Variable '"+(s.prtList[i] as ParsedExpr).value+"' not defined.");
						return;
					}
				} else {
					fStr += (s.prtList[i] as ParsedExpr).value.toString();
				}
			}
			dispatchEvent(new VMEvent(VMEvent.PRINT, {
				fString: fStr
			}));
		}
		private function execOpStatement(s:ParsedOpStmt):void {
			var opAval:ParsedExpr = (s.opA.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opA.value) : s.opA;
			var opBval:ParsedExpr = (s.opB.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opB.value) : s.opB;
			var opAbool = false;
			var opBbool = false;
			switch(s.type) {
				case "ADD":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT) {
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, Number(opAval.value) + Number(opBval.value)));
					} else {
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_STRLIT, opAval.value + opBval.value));
					}
				break;
				case "SUB":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT) {
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, Number(opAval.value)-Number(opBval.value)));
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "Substraction operation over non numerical values is illegal.");
						return;
					}
				break;
				case "MUL":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT) {
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT,Number(opAval.value)*Number(opBval.value)));
					} else {
						if(opBval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT) {
							var fStr:String = "";
							for(var i = 0; i < Number(opBval.value); i++) {
								fStr += opAval.value;
							}
							_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_STRLIT,fStr));
						}
					}
				break;
				case "DIV":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT) {
						if(opBval.value == "0") {
							throwRuntimeErr(VirtualMachine.RUNTIMEERR_DIVBYZERO, s.tokenizedStatement.getTokenAt(0).line, "Division by zero.");
							return;
						}
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT,Number(opAval.value)/Number(opBval.value)));
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "Division operation over non numerical values is illegal.");
						return;
					}
				break;
				case "MOD":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT) {
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT,Number(opAval.value)%Number(opBval.value)));
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "Module operation over non numerical values is illegal.");
						return;
					}
				break;
				case "EXP":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_NUMLIT) {
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, Math.pow(Number(opAval.value), Number(opBval.value))));
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "Exponential operation over non numerical values is illegal.");
						return;
					}
				break;
				case "AND":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						opAbool = (opAval.value=="true") ? true : false;
						opBbool = (opBval.value=="true") ? true : false;
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT, opAbool && opBbool));
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "AND operation over non boolean values is illegal.");
						return;
					}
				break;
				case "OR":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						opAbool = (opAval.value=="true") ? true : false;
						opBbool = (opBval.value=="true") ? true : false;
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT, opAbool || opBbool));
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "OR operation over non boolean values is illegal.");
						return;
					}
				break;
				case "XOR":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						opAbool = (opAval.value=="true") ? true : false;
						opBbool = (opBval.value=="true") ? true : false;
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT, (!(opAbool && opBbool) && (opAbool || opBbool))));
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "XOR operation over non boolean values is illegal.");
						return;
					}
				break;
				case "NOT":
					if(opAval.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT && opBval.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						opAbool = (opAval.value=="true") ? true : false;
						opBbool = (opBval.value=="true") ? true : false;
						_context.variableTable.setVar(s.saveTo, new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT, !opAbool));
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "NOT operation over non boolean values is illegal.");
						return;
					}
				break;
			}
		}
		private function execJmpStatement(s:ParsedJmpStmt):void {
			var opA:ParsedExpr = null;
			var opB:ParsedExpr = null;
			switch(s.type) {
				case "JMP":
					_cursor = _context.labelDir.getLineFor(s.goTo);
				break;
				case "JEQ":
					opA = (s.opA.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opA.value) : s.opA; 
					opB = (s.opB.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opB.value) : s.opB;
					if(opA.value == opB.value) {
						_cursor = _context.labelDir.getLineFor(s.goTo);
					} else {
						_cursor++;
					}
				break;
				case "JNE":
					opA = (s.opA.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opA.value) : s.opA; 
					opB = (s.opB.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opB.value) : s.opB;
					if(opA.value != opB.value) {
						_cursor = _context.labelDir.getLineFor(s.goTo);
					} else {
						_cursor++;
					}
				break;
				case "JLT":
					opA = (s.opA.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opA.value) : s.opA; 
					opB = (s.opB.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opB.value) : s.opB;
					opA = (opA.type == ParsedExpr.PARSED_EXPR_TYPE_STRLIT) ? new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, opA.value.length) : opA;
					opB = (opB.type == ParsedExpr.PARSED_EXPR_TYPE_STRLIT) ? new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, opB.value.length) : opB;
					if(opA.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT || opB.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_BADVARTYPE, s.tokenizedStatement.getTokenAt(0).line, "Can not use boolean values at JLT statements.");
						return;
					}
					if(Number(opA.value) < Number(opB.value)) {
						_cursor = _context.labelDir.getLineFor(s.goTo);
					} else {
						_cursor++;
					}
				break;
				case "JLE":
					opA = (s.opA.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opA.value) : s.opA; 
					opB = (s.opB.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opB.value) : s.opB;
					opA = (opA.type == ParsedExpr.PARSED_EXPR_TYPE_STRLIT) ? new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, opA.value.length) : opA;
					opB = (opB.type == ParsedExpr.PARSED_EXPR_TYPE_STRLIT) ? new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, opB.value.length) : opB;
					if(opA.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT || opB.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_BADVARTYPE, s.tokenizedStatement.getTokenAt(0).line, "Can not use boolean values at JLT statements.");
						return;
					}
					if(Number(opA.value) <= Number(opB.value)) {
						_cursor = _context.labelDir.getLineFor(s.goTo);
					} else {
						_cursor++;
					}
				break;
				case "JGT":
					opA = (s.opA.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opA.value) : s.opA; 
					opB = (s.opB.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opB.value) : s.opB;
					opA = (opA.type == ParsedExpr.PARSED_EXPR_TYPE_STRLIT) ? new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, opA.value.length) : opA;
					opB = (opB.type == ParsedExpr.PARSED_EXPR_TYPE_STRLIT) ? new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, opB.value.length) : opB;
					if(opA.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT || opB.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_BADVARTYPE, s.tokenizedStatement.getTokenAt(0).line, "Can not use boolean values at JLT statements.");
						return;
					}
					if(Number(opA.value) > Number(opB.value)) {
						_cursor = _context.labelDir.getLineFor(s.goTo);
					} else {
						_cursor++;
					}
				break;
				case "JGE":
					opA = (s.opA.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opA.value) : s.opA; 
					opB = (s.opB.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opB.value) : s.opB;
					opA = (opA.type == ParsedExpr.PARSED_EXPR_TYPE_STRLIT) ? new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, opA.value.length) : opA;
					opB = (opB.type == ParsedExpr.PARSED_EXPR_TYPE_STRLIT) ? new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, opB.value.length) : opB;
					if(opA.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT || opB.type == ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_BADVARTYPE, s.tokenizedStatement.getTokenAt(0).line, "Can not use boolean values at JLT statements.");
						return;
					}
					if(Number(opA.value) >= Number(opB.value)) {
						_cursor = _context.labelDir.getLineFor(s.goTo);
					} else {
						_cursor++;
					}
				break;
				case "JTR":
					opA = (s.opA.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opA.value) : s.opA; 
					if(opA.type != ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_BADVARTYPE, s.tokenizedStatement.getTokenAt(0).line, "Most use Boolean values on JTR statements.");
						return;
					}
					if(opA.value == "true") {
						_cursor = _context.labelDir.getLineFor(s.goTo);
					} else {
						_cursor++;
					}
				break;
				case "JFA":
					opA = (s.opA.type == ParsedExpr.PARSED_EXPR_TYPE_VAR) ? _context.variableTable.getVar(s.opA.value) : s.opA; 
					if(opA.type != ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT) {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_BADVARTYPE, s.tokenizedStatement.getTokenAt(0).line, "Most use Boolean values on JTR statements.");
						return;
					}
					if(opA.value == "false") {
						_cursor = _context.labelDir.getLineFor(s.goTo);
					} else {
						_cursor++;
					}
				break;
				_cursor++;
			}
		}
		private function execEvtStatement(s:ParsedEvtStmt):void {
			var fArr:Array = new Array();
			for(var i = 0; i < s.varList.length; i++) {
				if((s.varList[i] as ParsedExpr).type == ParsedExpr.PARSED_EXPR_TYPE_VAR) {
					var varVal:* = _context.variableTable.getVar((s.varList[i] as ParsedExpr).value);
					if(varVal != null) {
						fArr.push((varVal as ParsedExpr).value);
					} else {
						throwRuntimeErr(VirtualMachine.RUNTIMEERR_VARNOTDEF, s.tokenizedStatement.getTokenAt(0).line, "Variable '"+(s.varList[i] as ParsedExpr).value+"' not defined.");
						return;
					}
				} else {
					fArr.push((s.varList[i] as ParsedExpr).value);
				}
			}
			dispatchEvent(new VMEvent(VMEvent.SCRIPT_EVENT, {
				args: fArr
			}));
		}
		
		private function on_lexerError(evt:LexerEvent):void {
			_hasErrors = true;
			dispatchEvent(evt);
		}
		
		private function on_parserError(evt:ParserEvent):void {
			_hasErrors = true;
			dispatchEvent(evt);
		}
		
		private function throwRuntimeErr(errcode:uint, lne, msg:String):void {
			_isRunning = false;
			dispatchEvent(new VMEvent(VMEvent.RUNTIME_ERROR, {
				code: errcode,
				line: lne,
				message: msg
			}));
		}

	}
	
}
