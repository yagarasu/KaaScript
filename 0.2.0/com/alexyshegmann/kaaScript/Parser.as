package com.alexyshegmann.kaaScript {
	
	import com.alexyshegmann.kaaScript.tokens.*;
	import com.alexyshegmann.kaaScript.TokenizedScript;
	import com.alexyshegmann.kaaScript.TokenizedStatement;
	import com.alexyshegmann.kaaScript.parsing.*;
	import com.alexyshegmann.kaaScript.ParsedScript;
	import com.alexyshegmann.kaaScript.events.ParserEvent;
	import flash.events.EventDispatcher;
	
	public class Parser extends EventDispatcher {
		
		public static const PARSER_STMT_LABEL:RegExp = /^T_LABEL\sT_ENDST$/;
		public static const PARSER_STMT_SET:RegExp = /^T_SET\sT_VAR\sT_COMA\s(T_NUM|T_STR|T_BOOL|T_VAR)\sT_ENDST$/;
		public static const PARSER_STMT_PRT:RegExp = /^T_PRT(\s(T_VAR|T_NUM|T_STR|T_BOOL)?(\sT_COMA\s(T_VAR|T_NUM|T_STR|T_BOOL))*)\sT_ENDST$/;
		//public static const PARSER_STMT_PRT:RegExp = /^T_PRT(((\s(T_NUM|T_STR|T_VAR))?\sT_ENDST)|(\s(T_NUM|T_STR|T_VAR)\sT_COMA)*(\s(T_NUM|T_STR|T_VAR)\sT_ENDST))$/;
		public static const PARSER_STMT_END:RegExp = /^T_END\sT_ENDST/;
		public static const PARSER_STMT_MATHOP:RegExp = /^T_(ADD|SUB|MUL|DIV|MOD|EXP)\sT_VAR\sT_COMA\s(T_NUM|T_VAR|T_STR)\sT_COMA\s(T_NUM|T_VAR)\sT_ENDST$/;
		public static const PARSER_STMT_BOOLOP:RegExp = /^T_(AND|OR|XOR|NOT)\sT_VAR\sT_COMA\s(T_BOOL|T_VAR)(\sT_COMA\s(T_BOOL|T_VAR))?\sT_ENDST$/;
		public static const PARSER_STMT_JMP:RegExp = /^T_(JMP|JEQ|JNE|JLT|JGT|JLE|JGE|JTR|JFA)(\s(T_NUM|T_STR|T_VAR|T_BOOL)\sT_COMA){0,2}\sT_LABEL\sT_ENDST$/;
		public static const PARSER_STMT_EVT:RegExp = /^T_EVT\s(T_VAR|T_STR)(\sT_COMA\s(T_VAR|T_NUM|T_STR|T_BOOL))*\sT_ENDST$/;
		
		private var _tokenizedScript:TokenizedScript = null;
		private var _parsedScript:ParsedScript = null;
		private var _cursor = 0;
		private var _cStat:TokenizedStatement;
		private var _hasErrors:Boolean = false;

		public function Parser(tokenizedScript:TokenizedScript=null) {
			if(tokenizedScript!==null) {
				_tokenizedScript = tokenizedScript;
				parse();
			}
		}
		
		public function get hasErrors():Boolean { return _hasErrors; }
		
		public function get tokenizedScript():TokenizedScript { return _tokenizedScript; }
		public function set tokenizedScript(tokenizedScript:TokenizedScript):void {
			_tokenizedScript = tokenizedScript;
			parse();
		}
		
		public function get parsedScript():ParsedScript { return _parsedScript; }
		
		private function parse():void {
			_hasErrors = false;
			_cursor = 0;
			_parsedScript = new ParsedScript();
			while(_cursor < _tokenizedScript.length) {
				//trace(_cursor+"/"+_tokenizedScript.length+" | Starting:"+_tokenizedScript.getStatementAt(_cursor).tokenizedString());
				parseStatement(_tokenizedScript.getStatementAt(_cursor));
				//trace("Just parsed.");
				_cursor++;
			}
			//trace(_parsedScript);
		}
		
		private function parseStatement_LABEL(statement:TokenizedStatement):void {
			_parsedScript.pushStatement((new ParsedLabelStmt(statement, (statement.getTokenAt(0) as TokenLabel).identifier, (statement.getTokenAt(0) as TokenLabel).address) as ParsedStatement));
			return;
		}
		private function parseStatement_SET(statement:TokenizedStatement):void {
			var stmtExpr:ParsedExpr = null;
			if(statement.getTokenAt(3) is TokenStrLiteral) { stmtExpr = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_STRLIT, (statement.getTokenAt(3) as TokenLiteral).literalValue); }
			if(statement.getTokenAt(3) is TokenNumLiteral) { stmtExpr = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, (statement.getTokenAt(3) as TokenLiteral).literalValue); }
			if(statement.getTokenAt(3) is TokenBoolLiteral) { stmtExpr = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT, (statement.getTokenAt(3) as TokenLiteral).literalValue); }
			if(statement.getTokenAt(3) is TokenVariable) { stmtExpr = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_VAR, (statement.getTokenAt(3) as TokenVariable).identifier); }
			var pSetStat:ParsedSetStmt = new ParsedSetStmt(statement, (statement.getTokenAt(1) as TokenVariable).identifier, stmtExpr);
			_parsedScript.pushStatement((pSetStat as ParsedStatement));
			return;
		}
		private function parseStatement_END(statement:TokenizedStatement):void {
			_parsedScript.pushStatement((new ParsedEndStmt(statement) as ParsedStatement));
			return;	
		}
		private function parseStatement_PRT(statement:TokenizedStatement):void {
			var prtStat:ParsedPrtStmt = new ParsedPrtStmt(statement);
			for(var idx = 0; idx<statement.length; idx++) {
				if(statement.getTokenAt(idx) is TokenLiteral) {
					if(statement.getTokenAt(idx) is TokenStrLiteral) { prtStat.pushPrtExp(new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_STRLIT, (statement.getTokenAt(idx) as TokenLiteral).literalValue)); }
					if(statement.getTokenAt(idx) is TokenNumLiteral) { prtStat.pushPrtExp(new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, (statement.getTokenAt(idx) as TokenLiteral).literalValue)); }
					if(statement.getTokenAt(idx) is TokenBoolLiteral) { prtStat.pushPrtExp(new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT, (statement.getTokenAt(idx) as TokenLiteral).literalValue)); }					
				}
				if(statement.getTokenAt(idx) is TokenVariable) {
					prtStat.pushPrtExp(new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_VAR, (statement.getTokenAt(idx) as TokenVariable).identifier));
				}
			}
			_parsedScript.pushStatement((prtStat as ParsedStatement));
			return;
		}
		private function parseStatement_MATHOP(statement:TokenizedStatement):void {
			var type:String = (statement.getTokenAt(0) as TokenKeyword).keyword;
			var opA:ParsedExpr = null;
			if(statement.getTokenAt(3) is TokenVariable) { opA = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_VAR, (statement.getTokenAt(3) as TokenVariable).identifier); }
			if(statement.getTokenAt(3) is TokenNumLiteral) { opA = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, (statement.getTokenAt(3) as TokenNumLiteral).literalValue); }
			var opB:ParsedExpr = null;
			if(statement.getTokenAt(5) is TokenVariable) { opB = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_VAR, (statement.getTokenAt(5) as TokenVariable).identifier); }
			if(statement.getTokenAt(5) is TokenNumLiteral) { opB = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, (statement.getTokenAt(5) as TokenNumLiteral).literalValue); }
			_parsedScript.pushStatement((new ParsedOpStmt(statement, type,(statement.getTokenAt(1) as TokenVariable).identifier, opA, opB) as ParsedStatement));
			return;
		}
		private function parseStatement_BOOLOP(statement:TokenizedStatement):void {
			var type:String = (statement.getTokenAt(0) as TokenKeyword).keyword;
			var opA:ParsedExpr = null;
			if(statement.getTokenAt(3) is TokenVariable) { opA = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_VAR, (statement.getTokenAt(3) as TokenVariable).identifier); }
			if(statement.getTokenAt(3) is TokenBoolLiteral) { opA = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT, (statement.getTokenAt(3) as TokenBoolLiteral).literalValue); }
			var opB:ParsedExpr = null;
			if(statement.length > 5) {
				if(statement.getTokenAt(5) is TokenVariable) { opB = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_VAR, (statement.getTokenAt(5) as TokenVariable).identifier); }
				if(statement.getTokenAt(5) is TokenNumLiteral) { opB = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, (statement.getTokenAt(5) as TokenNumLiteral).literalValue); }
			} else {
				opB = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT, false);
			}
			_parsedScript.pushStatement((new ParsedOpStmt(statement, type,(statement.getTokenAt(1) as TokenVariable).identifier, opA, opB) as ParsedStatement));
			return;
		}
		private function parseStatement_JMP(statement:TokenizedStatement):void {
			var type:String = (statement.getTokenAt(0) as TokenKeyword).keyword;
			var label:String = (statement.getTokenAt(statement.length-2) as TokenLabel).identifier;
			var opA:ParsedExpr = null;
			var opB:ParsedExpr = null;
			if(statement.length > 4) {
				if(statement.getTokenAt(1) is TokenVariable) { opA = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_VAR, (statement.getTokenAt(1) as TokenVariable).identifier); }
				if(statement.getTokenAt(1) is TokenNumLiteral) { opA = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, (statement.getTokenAt(1) as TokenLiteral).literalValue); }
				if(statement.getTokenAt(1) is TokenStrLiteral) { opA = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_STRLIT, (statement.getTokenAt(1) as TokenLiteral).literalValue); }
				if(statement.getTokenAt(3) is TokenVariable) { opB = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_VAR, (statement.getTokenAt(3) as TokenVariable).identifier); }
				if(statement.getTokenAt(3) is TokenNumLiteral) { opB = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, (statement.getTokenAt(3) as TokenLiteral).literalValue); }
				if(statement.getTokenAt(3) is TokenStrLiteral) { opB = new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_STRLIT, (statement.getTokenAt(3) as TokenLiteral).literalValue); }
			}
			_parsedScript.pushStatement((new ParsedJmpStmt(statement, type, label, opA, opB) as ParsedStatement));
			return;
		}
		private function parseStatement_EVT(statement:TokenizedStatement):void {
			var evtStat:ParsedEvtStmt = new ParsedEvtStmt(statement);
			for(var idx = 0; idx<statement.length; idx++) {
				if(statement.getTokenAt(idx) is TokenLiteral) {
					if(statement.getTokenAt(idx) is TokenStrLiteral) { evtStat.pushEvtExp(new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_STRLIT, (statement.getTokenAt(idx) as TokenLiteral).literalValue)); }
					if(statement.getTokenAt(idx) is TokenNumLiteral) { evtStat.pushEvtExp(new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_NUMLIT, (statement.getTokenAt(idx) as TokenLiteral).literalValue)); }
					if(statement.getTokenAt(idx) is TokenBoolLiteral) { evtStat.pushEvtExp(new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_BOOLLIT, (statement.getTokenAt(idx) as TokenLiteral).literalValue)); }					
				}
				if(statement.getTokenAt(idx) is TokenVariable) {
					evtStat.pushEvtExp(new ParsedExpr(ParsedExpr.PARSED_EXPR_TYPE_VAR, (statement.getTokenAt(idx) as TokenVariable).identifier));
				}
			}
			_parsedScript.pushStatement((evtStat as ParsedStatement));
			return;
		}
		
		private function parseStatement(statement:TokenizedStatement):void {
			if(PARSER_STMT_LABEL.test(statement.tokenizedString())) {
				//trace("Is label");
				parseStatement_LABEL(statement);
				return;
			}
			if(PARSER_STMT_SET.test(statement.tokenizedString())) {
				//trace("Is set var");
				parseStatement_SET(statement);
				return;
			}
			if(PARSER_STMT_END.test(statement.tokenizedString())) {
				//trace("Is end");
				parseStatement_END(statement);
				return;
			}
			if(PARSER_STMT_PRT.test(statement.tokenizedString())) {
				//trace("Is print");
				parseStatement_PRT(statement);
				return;
			}
			if(PARSER_STMT_MATHOP.test(statement.tokenizedString())) {
				//trace("Is is mathop");
				parseStatement_MATHOP(statement);
				return;
			}
			if(PARSER_STMT_BOOLOP.test(statement.tokenizedString())) {
				//trace("Is boolop");
				parseStatement_BOOLOP(statement);
				return;
			}
			if(PARSER_STMT_JMP.test(statement.tokenizedString())) {
				//trace("Is jmp");
				parseStatement_JMP(statement);
				return;
			}
			if(PARSER_STMT_EVT.test(statement.tokenizedString())) {
				//trace("Is EVT");
				parseStatement_EVT(statement);
				return;
			}
			_hasErrors = true;
			dispatchEvent(new ParserEvent(ParserEvent.UNKNOWN_STATEMENT, statement.getTokenAt(0).line, statement.getTokenAt(0).position, ""));
		}

	}
	
}
