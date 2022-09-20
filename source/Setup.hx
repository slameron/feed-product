package;

import flixel.FlxG;
import flixel.FlxState;

class Setup extends FlxState
{
	override public function create()
	{
		super.create();

		FlxG.save.bind('FEED_PRODUCT');

		if (FlxG.save.data.musVol == null)
			FlxG.save.data.musVol = 1;
		if (FlxG.save.data.sndVol == null)
			FlxG.save.data.sndVol = 1;
		if (FlxG.save.data.mastVol == null)
			FlxG.save.data.mastVol = 1;

		if (FlxG.save.data.fullscreen != null)
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		FlxG.save.flush();

		FlxG.switchState(new states.MenuState());
	}
}
