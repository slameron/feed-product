package;

import flixel.FlxGame;
import flixel.system.FlxAssets;
import openfl.display.Sprite;
import states.MenuState;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(640, 360, Setup, 1, 60, 60, true, true));
	}
}
