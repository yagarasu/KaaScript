#KaaScript

##A script inside a script
KaaScript is a Virtual Machine for a small scripting language written in ActionScript 3.
¿Why should I use a scripting language inside a scripting language? Well, for **game development**, of course!
Let's picture this. You are making an online game with a large ammount of items. You will update this list every wednesday to keep your players exploring and playing. You don't want to make an endless folder of items, so you plan to use an XML file to store those items, but... how can you make an item that works only if your HP is below 5? Or a killer sword that poisons the enemy and also gives you +5 on strength? The XML specs and the parser will be as long as hell. Here's where a scripting language comes in handy: you store a script for every item to interact with the core.

##Implementation
It's as easy as include the lib and intantiate a VirtualMachine.
```AS3
var vm:VirtualMachine = new VirtualMachine();
vm.script = "PRT \"Hello World!\";";
vm.run();
```

##Syntax
KaaScript is inspired by Assembler language. There are no functions, no classes, just commands, variables and literals. Every statement must end with ;

###Labels
As there are no functions or subprocedures, you can use labels to separate chunks of code to reuse or iterate over. Labels are marked with a : as the first character of the identifier and contain only alphanumeric characters.

```
:init;
  PRT "Hello world!";
  JMP :foo;
  END;
:foo;
  PRT "I'm in foo";
  END;
```

###Variables
Variables are assigned by the SET command. The identifier must start with $ character and contain only alphanumeric characters.

```
SET $foo, 10;
PRT $foo;
```

You can assign numeric, string and boolean literals.

###PRT command and the Print Event
If you want some output to debug, you can use ```trace()``` in AS3, but what if you want to use a custom made console for in game debugging?
I've made the main output a VirtualMachine Event to pipe the output through whatever interface you want.

```AS3
var vm:VirtualMachine = new VirtualMachine();
vm.addEventListener(VMEvent.PRINT, onPrint, false, 0, true);
vm.script = "PRT \"Hello World!\";";
vm.run();

private function onPrint(e:VMEvent):void {
  trace("VM said> "+e.params.fString);
}
```
Will print "VM said> Hello World!" in the console.

You can concatenate the output by separating the parts with commas.
```
PRT "Hello", "World", "!!!";
```

###Math operations
You can use the math commands to perform basic numeric operations. The syntax is opperands first, then variable to write the answer in:
```
SET $a, 2;
SET $b, 3;
SET $c, 0;
ADD $a, $b, $c;
PRT $c;
```
Will print 5.

* ADD $a, $b, $c;
* SUB $a, $b, $c;
* MUL $a, $b, $c;
* DIV $a, $b, $c;
* MOD $a, $b, $c;
* EXP $a, $b, $c;
* AND $a, $b, $c;
* OR $a, $b, $c;
* XOR $a, $b, $c;
* NOT $a, $b, $c;*
..* *NOT command has a bug: must accept only two params. It's using only the first opperand, NOTing it, then saving it into the third opperand. Second opperand is ignored.

ADD applied to strings will concatenate them.
MUL applied to strings will repeat A(str) B(num) times, then save it to C.

###Jumping and conditional jumping
The main flow control is created by jumping to labels.
There are 9 jumping commands:
* JMP :label;         : Jump to :label
* JEQ $a, $b, :label  : Jump to :label if $a and $b are equal
* JNE $a, $b, :label  : Jump to :label if $a and $b are different
* JLT $a, $b, :label  : Jump to :label if $a is lesser than $b (if used on strings, length is used)
* JLE $a, $b, :label  : Jump to :label if $a is lesser than or equal to $b (if used on strings, length is used)
* JGT $a, $b, :label  : Jump to :label if $a is greater than $b (if used on strings, length is used)
* JGE $a, $b, :label  : Jump to :label if $a is greater than or equal to $b (if used on strings, length is used)
* JTR $a, :label      : Jump to :label if $a is TRUE
* JFA $a, :label      : Jump to :label if $a is FALSE

This is a full featured For Loop starting on 4, counting until 20 in 2 by 2 steps and breaking on 18.
```
:init;
  SET $i, 4;
  SET $stp, 2;
  SET $lmt, 20;
  :for;
    PRT $i;
    ADD $i, $stp, $i;
    JLT $i, $lmt, :for;
    JEQ $i, 18, :break;
  :break;
  PRT "Stopped at", $i;
```

###Events
To react with the implementing code, the main interface are custom events triggered by the EVT command.
Yo can pass as many params as you want to the custom event.

```AS3
var vm:VirtualMachine = new VirtualMachine();
vm.addEventListener(VMEvent.SCRIPT_EVENT, onEvt, false, 0, true);
vm.script = "----- KAASCRIPT HERE -----";
vm.run();

private function onEvt(e:VMEvent):void {
  trace("Event triggered!> "+e.params.args);
  if((e.params.args as Array)[0]=="damage") {
    dam = (e.params.args as Array)[1];
    // do core functions here. You can use the new variable dam to get how much damage the player gets (10 in this case).
  }
}
```
And in kaaScript:
```
SET $a, 10;
EVT "damage", $a;
```

##To sum it up
Yeah, it's very basic, but I think it has great potential. There are a lot of bugs and a lot of features to include.
I worked on some small features for the VM like dynamically changing kaa variables. I'm open to suggestions, but it's not my priority right now.

