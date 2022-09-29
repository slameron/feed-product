package util;

import flixel.input.keyboard.FlxKey;

class Controls
{
	public var accept:Bool;
	public var back:Bool;
	public var up:Bool;
	public var down:Bool;
	public var left:Bool;
	public var right:Bool;
	public var upP:Bool;
	public var downP:Bool;
	public var leftP:Bool;
	public var rightP:Bool;
	public var interact:Bool;

	public function new() {}

	public static function getControl(control:String):Array<FlxKey>
		return controls[control];

	public static function keyPrompt(control:String):String
		return controls[control][0].toString();

	static var controls:Map<String, Array<FlxKey>> = [
		'accept' => [SPACE, ENTER],
		'back' => [ESCAPE],
		'up' => [UP, W],
		'down' => [DOWN, S],
		'left' => [LEFT, A],
		'right' => [RIGHT, D],
		'interact' => [E]
	];

	public function update(elapsed:Float)
	{
		accept = FlxG.keys.anyJustPressed(getControl('accept'));
		back = FlxG.keys.anyJustPressed(getControl('back'));

		up = FlxG.keys.anyPressed(getControl('up'));
		down = FlxG.keys.anyPressed(getControl('down'));
		left = FlxG.keys.anyPressed(getControl('left'));
		right = FlxG.keys.anyPressed(getControl('right'));
		upP = FlxG.keys.anyJustPressed(getControl('up'));
		downP = FlxG.keys.anyJustPressed(getControl('down'));
		leftP = FlxG.keys.anyJustPressed(getControl('left'));
		rightP = FlxG.keys.anyJustPressed(getControl('right'));
		interact = FlxG.keys.anyJustPressed(getControl('interact'));
	}
}
