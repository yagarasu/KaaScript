package com.alexyshegmann.kaaScript.virtualmachine {
	
	import com.alexyshegmann.kaaScript.virtualmachine.VMVariableTable;
	import com.alexyshegmann.kaaScript.virtualmachine.VMLabelDirectory;
	
	public class VMContext {
		
		public var variableTable:VMVariableTable = null;
		public var labelDir:VMLabelDirectory = null;

		public function VMContext() {
			variableTable = new VMVariableTable();
			labelDir = new VMLabelDirectory();
		}

	}
	
}
