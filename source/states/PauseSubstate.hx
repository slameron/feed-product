package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.util.FlxSpriteUtil;
import openfl.geom.Rectangle;

class PauseSubstate extends DefaultSubstate
{
	override public function new()
	{
		super();
	}

	override function addbg()
	{
		var masked:FlxSprite = new FlxSprite();
		var thingy:FlxUI9SliceSprite = new FlxUI9SliceSprite(0, 0, 'assets/images/diaslice-feed.png', new Rectangle(0, 0, FlxG.width / 3, FlxG.height - 60),
			[8 * 3, 8 * 3, 15 * 3, 15 * 3]);
		var dbg = FlxGridOverlay.create(Std.int(thingy.width / 4), Std.int(thingy.width / 4), Math.floor(thingy.width), Math.floor(thingy.height), true,
			0xff000000, 0xFF2F2F2F);

		FlxSpriteUtil.alphaMaskFlxSprite(dbg, thingy, masked);

		add(masked);
		// masked.velocity.set(30, 30);

		add(thingy);
		thingy.alpha = .7;
		masked.setPosition(60, 30);
		thingy.setPosition(60, 30);
	}
}
