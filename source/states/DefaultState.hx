package states;

class DefaultState extends FlxState
{
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Sound.updateSounds(elapsed);
	}
}
