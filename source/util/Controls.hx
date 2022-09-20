package util;

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
	public var dodge:Bool;

	public function new() {}

	public function update(elapsed:Float)
	{
		accept = FlxG.keys.anyJustPressed([SPACE, ENTER]);
		back = FlxG.keys.anyJustPressed([ESCAPE]);

		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);
		upP = FlxG.keys.anyJustPressed([UP, W]);
		downP = FlxG.keys.anyJustPressed([DOWN, S]);
		leftP = FlxG.keys.anyJustPressed([LEFT, A]);
		rightP = FlxG.keys.anyJustPressed([RIGHT, D]);
		dodge = FlxG.keys.anyJustPressed([SHIFT, SPACE]);
	}
}
