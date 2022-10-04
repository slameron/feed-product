package states;

import flixel.effects.particles.FlxEmitter;

class SpaceStation extends DefaultState
{
	override public function create()
	{
		var amt = 500;
		var time = 5;
		bgColor = FlxColor.BLACK;
		var coolSplash:FlxEmitter = new FlxEmitter(FlxG.width / 2, FlxG.height / 2, amt);
		coolSplash.makeParticles(2, 2, FlxColor.WHITE, amt);
		coolSplash.alpha.set(.1, .7, .1, .7);
		coolSplash.lifespan.set(time + .5);
		coolSplash.speed.set(0, FlxG.width / time, 0, 0);
		add(coolSplash);
		coolSplash.active = false;

		coolSplash.start(false, time / amt);
		coolSplash.update(time);

		var moon = new FlxSprite(0, 0).loadGraphic('assets/images/moon.png', true, 250, 250);
		moon.animation.add('spin', [for (i in 0...19) i], 4);
		moon.scale.set(.385, .385);
		moon.updateHitbox();
		moon.setPosition(FlxG.width - moon.width - 80, 70);
		moon.animation.play('spin');
		add(moon);

		var earth = new FlxSprite(0, 0).loadGraphic('assets/images/earth.png', true, 250, 250);
		earth.animation.add('spin', [for (i in 0...30) i], 2);
		earth.scale.set(.51, .51);
		earth.updateHitbox();
		earth.setPosition(120, FlxG.height - earth.height - 52);
		earth.animation.play('spin');
		add(earth);
	}
}
