package states;

import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;

class SpaceStation extends DefaultState
{
	var earth:FlxSprite;
	var moon:FlxSprite;
	var places:Map<String, Array<{name:String, onSelect:() -> Void}>> = [
		'Earth' => [
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			},
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			},
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			},
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			},
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			}
		],
		'Moon' => [
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			},
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			},
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			},
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			},
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new MenuState())
			}
		]
	];

	var earthOptions:FlxTypedGroup<MenuItem>;
	var moonOptions:FlxTypedGroup<MenuItem>;

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

		moon = new FlxSprite(0, 0).loadGraphic('assets/images/moon.png', true, 250, 250);
		moon.animation.add('spin', [for (i in 0...19) i], 4);
		moon.scale.set(.385, .385);
		moon.updateHitbox();
		moon.setPosition(FlxG.width - moon.width - 80, 70);
		moon.animation.play('spin');
		moonOptions = new FlxTypedGroup();
		add(moonOptions);
		add(moon);

		earth = new FlxSprite(0, 0).loadGraphic('assets/images/earth.png', true, 250, 250);
		earth.animation.add('spin', [for (i in 0...30) i], 2);
		earth.scale.set(.51, .51);
		earth.updateHitbox();
		earth.setPosition(120, FlxG.height - earth.height - 52);
		earth.animation.play('spin');
		earthOptions = new FlxTypedGroup();
		add(earthOptions);
		add(earth);

		for (planet in places.keys())
		{
			for (i in 0...places[planet].length)
			{
				var option = places[planet][i];

				var item = new MenuItem(0, 0, 0, option.name, 32);
				item.onInteract = option.onSelect;
				item.ID = i;

				item.clipLeft = planet == 'Earth' ? false : true;
				item.clipSpr = planet == 'Earth' ? earth : moon;

				var itemGrp = planet == 'Earth' ? earthOptions : moonOptions;
				itemGrp.add(item);
			}
		}
	}

	var curSelected:Int = 0;

	var planetSelected:FlxSprite = null;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		earthOptions.forEach(spr ->
		{
			var targetX = earth.x + earth.width + 20;
			var targetY = earth.y + earth.height / 2 - spr.height / 2;
			spr.x = FlxMath.lerp(spr.x, targetX, 0.2);
			spr.y = FlxMath.lerp(spr.y, targetY, 0.2);
		});

		moonOptions.forEach(spr ->
		{
			var targetX = moon.x - spr.width - 15;
			var targetY = moon.y + moon.height / 2 - spr.height / 2;
			//	spr.x = FlxMath.lerp(spr.x, targetX, 0.2);
			// spr.y = FlxMath.lerp(spr.y, targetY, 0.2);
		});
	}
}
