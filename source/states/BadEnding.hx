package states;

class BadEnding extends DefaultState
{
	var scrollText:FlxText;

	override public function create()
	{
		super.create();
		makeStars();
		var text = "You and the other people at the Lounge were hacked.\nYou all stay in the hospital for a while, and you and Violet become close.\nYou two date for a while, until Violet's Feed becomes inefficient and her brain begins to fail.\nUnable to handle the situation, you cut Violet off, slowly drifting from her.";
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
