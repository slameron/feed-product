package states;

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
			FlxG.camera.zoom = .6;
		Sound.swapOutside('pullup', !inside, .3);
	}
}
