package states;

import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;

class SpaceStation extends DefaultState
{
	var earth:FlxSprite;
	var moon:FlxSprite;
	var ship:FlxSprite;
	var places:Map<String, Array<{name:String, onSelect:() -> Void, unlocked:Bool}>> = [
		'Earth' => [
			{
				name: 'Home',
				onSelect: () -> FlxG.switchState(new PlayState('house')),
				unlocked: true
			},
			{
				name: 'Violet\'s',
				onSelect: () -> FlxG.switchState(new MenuState()),
				unlocked: FlxG.save.data.violetHouse
			}
		],
		'Moon' => [
			{
				name: 'Ricochet Lounge',
				onSelect: () -> FlxG.switchState(new RicochetLounge(false)),
				unlocked: FlxG.save.data.spokeMarty
			}
		]
	];

	var earthOptions:FlxTypedGroup<MenuItem>;
	var moonOptions:FlxTypedGroup<MenuItem>;

	override public function create()
	{
		super.create();
		makeStars();
		Sound.playMusic('molotov', .2);

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
			var k:Int = 0;
			for (i in 0...places[planet].length)
			{
				var option = places[planet][i];
				if (!option.unlocked)
					continue;

				var item = new MenuItem(0, 0, 0, option.name, 32);
				item.onInteract = option.onSelect;
				item.ID = k;

				item.clipLeft = planet == 'Earth' ? false : true;
				item.clipSpr = planet == 'Earth' ? earth : moon;

				var itemGrp = planet == 'Earth' ? earthOptions : moonOptions;

				item.setPosition(planet == 'Earth' ? earth.x - item.width : moon.x + moon.width, item.clipSpr.y + item.clipSpr.height / 2 - item.height / 2);
				itemGrp.add(item);
				k++;
			}
		}

		var daText = new FlxText(0, 0, 0, 'Use arrow keys to navigate, enter to select.', 24);
		add(daText);
		daText.screenCenter(X);
		daText.y = 5;

		ship = new FlxSprite().loadGraphic('assets/images/upcar-old.png', true, 32, 16);
		ship.animation.add('float', [1]);
		ship.animation.play('float');
		ship.flipX = true;
		add(ship);
		ship.scale.set(6, 6);
		ship.updateHitbox();
		ship.setPosition(FlxG.width - ship.width - 10, FlxG.height - ship.height - 10);
		FlxTween.tween(ship, {y: ship.y - 20}, 3, {ease: FlxEase.smootherStepInOut, type: PINGPONG});
		s = new FlxEmitter(ship.x + ship.width / 2, ship.y + ship.height / 2, 200);
	}

	var s:FlxEmitter;

	var curSelected:Int = 0;

	var planetSelected(null, set):FlxSprite = null;

	function set_planetSelected(planet:FlxSprite)
	{
		curSelected = 0;
		return planetSelected = planet;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		s.setPosition(ship.x + ship.width / 2, ship.y + ship.height / 2);

		earthOptions.forEach(spr ->
		{
			var targetX = earth.x + earth.width + 20;
			var targetY = earth.y + earth.height / 2 - spr.height / 2;
			var offset = spr.height + 2;
			var offsetX = 10;
			targetY -= offset * (curSelected - spr.ID);
			targetX -= offsetX * (Math.abs(curSelected - spr.ID));
			if (planetSelected != earth)
				targetX = earth.x - spr.width;
			spr.x = FlxMath.lerp(spr.x, targetX, 0.2);
			spr.y = FlxMath.lerp(spr.y, targetY, 0.2);
			if (Math.abs(curSelected - spr.ID) >= 2)
				spr.visible = false;
			else
				spr.visible = true;
			if (spr.ID == curSelected)
				spr.color = FlxColor.YELLOW;
			else
				spr.color = FlxColor.WHITE;
		});

		moonOptions.forEach(spr ->
		{
			var targetX = moon.x - spr.width - 15;
			var targetY = moon.y + moon.height / 2 - spr.height / 2;
			var offset = spr.height + 2;
			var offsetX = 10;

			targetY -= offset * (curSelected - spr.ID);
			targetX += offsetX * (Math.abs(curSelected - spr.ID));
			if (planetSelected != moon)
				targetX = moon.x + moon.width;
			spr.x = FlxMath.lerp(spr.x, targetX, 0.2);
			spr.y = FlxMath.lerp(spr.y, targetY, 0.2);

			if (Math.abs(curSelected - spr.ID) >= 2)
				spr.visible = false;
			else
				spr.visible = true;

			if (spr.ID == curSelected)
				spr.color = FlxColor.YELLOW;
			else
				spr.color = FlxColor.WHITE;
		});

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(earth))
				planetSelected = earth;
			else if (FlxG.mouse.overlaps(moon))
				planetSelected = moon;
		}
		if (FlxG.keys.anyJustPressed([LEFT, A]))
			planetSelected = earth;
		if (FlxG.keys.anyJustPressed([RIGHT, D]))
			planetSelected = moon;

		if (FlxG.keys.anyJustPressed([DOWN, S]))
			change(1);

		if (FlxG.keys.anyJustPressed([UP, W]))
			change(-1);

		if (planetSelected != null && !selectedSomething)
			if (FlxG.keys.anyJustPressed([ENTER, SPACE]))
			{
				selectedSomething = true;
				FlxTween.cancelTweensOf(ship);

				s.makeParticles(3, 3, FlxColor.ORANGE, 200);
				var d = FlxAngle.angleBetween(planetSelected, ship, true);
				s.launchAngle.set(d - 15, d + 15);
				s.start(false, .05);
				insert(members.indexOf(ship), s);
				FlxTween.tween(ship, {
					x: planetSelected.x + planetSelected.width / 2 - ship.width / 2,
					y: planetSelected.y + planetSelected.height / 2 - ship.height / 2,
					"scale.x": .1,
					"scale.y": .1
				}, 5, {
					ease: FlxEase.quadInOut,
					onComplete: twn ->
					{
						var grp = planetSelected == moon ? moonOptions : earthOptions;
						grp.members[curSelected].onInteract();
					}
				});
			}
	}

	var selectedSomething:Bool = false;

	function change(by:Int)
	{
		curSelected += by;
		if (planetSelected != null)
			curSelected = Std.int(FlxMath.bound(curSelected, 0, planetSelected == moon ? moonOptions.members.length - 1 : earthOptions.members.length - 1));
		else
			curSelected = 0;
	}
}
