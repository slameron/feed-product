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
		Sound.swapOutside('pullup', !inside, .3);
	}
}
