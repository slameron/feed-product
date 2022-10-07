package objects;

import flixel.system.FlxAssets.FlxGraphicAsset;

class Interactable extends FlxSprite
{
	/**Function that calls when the player presses interact while near the object.**/
	public var onInteract:FlxSprite->Void;

	public var prompt:FlxText;
	public var beingHovered:Bool = false;
	public var canHover:Bool = true;

	override public function new(x:Float = 0, y:Float = 0, graphic:FlxGraphicAsset, onInteract:FlxSprite->Void, ?animated:Bool = false, ?width:Int,
			?height:Int)
	{
		super(x, y);
		animated ? loadGraphic(graphic, animated, width, height) : loadGraphic(graphic);
		this.onInteract = onInteract;

		prompt = new FlxText(0, 0, 0, Controls.keyPrompt('interact'), 48);
		prompt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2, 1);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		prompt.setPosition(x + width / 2 - prompt.width / 2, y - prompt.height - 10);
	}

	override public function draw()
	{
		if (beingHovered)
			prompt.draw();
		super.draw();
	}
}
