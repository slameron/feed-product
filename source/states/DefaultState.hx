package states;

import flixel.addons.transition.FlxTransitionableState;

class DefaultState extends FlxTransitionableState
{
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Sound.updateSounds(elapsed);
	}
}
