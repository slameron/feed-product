package states;

class GoodEnding extends DefaultState
{
	var scrollText:FlxText;

	override public function create()
	{
		super.create();
		makeStars();
		var text = "You survived the hacker at the Ricochet Lounge.\nYou, your friends, and Violet all become friends.\nSome of the other people at the Lounge (they were hiding, they were there I promise) got hacked.\nYou visited them in the hospital, feeling a bit of survivor's guilt.\nYou regret agreeing to go to the Lounge.\nViolet's Feed stays intact, and you two date for a while happily.";
		scrollText = new FlxText(0, FlxG.height + 10, FlxG.width, text, 64);
		add(scrollText);
		scrollText.moves = true;
		scrollText.velocity.y = -50;
		scrollText.alignment = CENTER;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (scrollText.y <= 0 - scrollText.height - 10)
			FlxG.switchState(new MenuState());
	}
}
