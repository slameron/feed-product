package states;

class SpaceTravel extends DefaultState
{
	override public function create()
	{
		super.create();
		makeStars();
	}
}
