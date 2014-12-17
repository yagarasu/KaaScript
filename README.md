#KaaScript

##A script inside a script
KaaScript is a Virtual Machine for a small scripting language written in ActionScript 3.
¿Why should I use a scripting language inside a scripting language? Well, for **game development**, of course!
Let's picture this. You are making an online game with a large ammount of items. You will update this list every wednesday to keep your players exploring and playing. You don't want to make an endless folder of items, so you plan to use an XML file to store those items, but... how can you make an item that works only if your HP is below 5? Or a killer sword that poisons the enemy and also gives you +5 on strength? The XML specs and the parser will be as long as hell. Here's where a scripting language comes in handy: you store a script for every item to interact with the core.

##Implementation
It's as easy as include the lib and intantiate a VirtualMachine.
```ActionScript3
var vm:VirtualMachine = null;
vm = new VirtualMachine();
vm.script = "PRT \"Hello World!\";";
vm.run();
```

##Syntax
KaaScript is inspired by Assambler.

-- WIP --
