package states;

import flixel.effects.particles.FlxEmitter;

class SpaceStation extends DefaultState
{
	override public function create()
	{
		bgColor = FlxColor.BLACK;
		var coolSplash:FlxEmitter = new FlxEmitter(FlxG.width, FlxG.height, 500);
		coolSplash.makeParticles(2, 2, FlxColor.WHITE, 500);
		coolSplash.alpha.set(.1, .7, .1, .7);
		add(coolSplash);
		coolSplash.active = false;

		coolSplash.start(false);
		coolSplash.update(5);
	}
}
