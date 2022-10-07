package states;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.util.FlxStringUtil;

class RicochetLounge extends DefaultState
{
	var inside:Bool;

	override public function new(inside:Bool)
	{
		this.inside = inside;
		super(inside ? 'rlInside' : 'rlOutside');
	}

	override public function create()
	{
		super.create();
		makeStars();
		if (!inside)
		{
			tiles.setTileProperties(4, ANY, null, null, 2);
			FlxG.camera.zoom = 1;
		}
		else
		{
			FlxG.camera.zoom = .6;
			var survive = new FlxCamera(0, 0, FlxG.width, FlxG.height);
			survive.bgColor = FlxColor.TRANSPARENT;
			FlxG.cameras.add(survive, false);
			surviveText = new FlxText(0, 10, FlxG.width, 'Survive the hacker\'s attacks for ', 16);
			surviveText.alignment = CENTER;
			surviveText.visible = false;
			add(surviveText);
			surviveText.cameras = [survive];
		}
		Sound.swapOutside('pullup', !inside, .3);
	}

	function hitPlayer(a:FlxObject, b:FlxObject)
	{
		if (Std.isOfType(b, FlxText)) // its a hacker attack
		{
			b.kill();

			a.kill();
			Sound.play('explode${FlxG.random.int(1, 3)}', .3);

			new FlxTimer().start(2, tmr -> FlxG.switchState(new BadEnding()));
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (hacker != null && hacker.fighting)
		{
			if ((ticks += elapsed) >= maxGap)
			{
				ticks = 0;

				var chars:String = '0123456789';
				var attack = new FlxText(hacker.x + hacker.width / 2, hacker.y + hacker.height / 2, 0, chars.charAt(FlxG.random.int(0, chars.length - 1)), 24);
				attack.color = FlxColor.LIME;
				hackerAttack.add(attack);
				attack.moves = true;
				attack.allowCollisions = ANY;
				var vel = FlxVelocity.velocityFromAngle(FlxAngle.angleBetween(hacker, player, true), FlxG.random.int(100, 300));
				attack.velocity.set(vel.x, vel.y);
			}
			surviveText.visible = true;
			if ((surviveTimeLeft -= elapsed) >= 0)
				surviveText.text = 'Avoid the hacker\'s attacks for ${FlxStringUtil.formatTime(surviveTimeLeft)}';
			else
				FlxG.switchState(new GoodEnding());

			FlxG.collide(player, hackerAttack, hitPlayer);
		}
	}

	var surviveText:FlxText;
	var surviveTimeLeft:Float = 120;
	var ticks:Float = 0;
	var maxGap:Float = 1;
}
