package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.geom.Rectangle;

class DialogueBox extends FlxTypedSpriteGroup<FlxSprite>
{
	var txt:FlxTypeText;
	var box:BoxGraphic;
	var nextBox:DialogueBox = null;
	var parentBox:DialogueBox = null;

	/**@param p Optional sprite to center the box on.
		@param text What you want the box to type out.
		@param speaker Nametag that will show up in the top left of the box.
		@param cinematic If true, the box will be centered on the bottom of the screen.
		@param feed If true, the box will be purple (feed message)**/
	override public function new(?p:FlxSprite, text:String = '', ?x:Float = 0, ?y:Float = 0, size:Int = 32, ?speaker:String = '', cinematic:Bool = false,
			feed:Bool = false)
	{
		super();

		var fieldW:Int = 0;

		if (p != null)
		{
			x = p.x + p.width / 2;
			y = p.y + 10;
		}
		var w = new FlxText(x + (size / 2), 0, 0, text, size);
		w.x -= w.width / 2;
		x = w.x;
		if (w.x + w.width >= FlxG.width)
		{
			fieldW = Std.int(FlxG.width - x - FlxG.random.int(30, 80));
			fieldW -= size;
		}
		if (cinematic)
		{
			size = 32;
			x = 50;

			fieldW = Std.int(FlxG.width - 100) - size;
		}
		w = null;
		txt = new FlxTypeText(x + (size / 2), y + (size / 4) + 4, fieldW, text, size);
		txt.text = text;
		if (cinematic)
		{
			y = FlxG.height - txt.height - size - 10;
			txt.y = y + (size / 4) + 5;
		}

		if (!feed && !cinematic)
			txt.color = FlxColor.BLACK;
		else
			txt.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);
		txt.useDefaultSound = false;
		txt.finishSounds = true;
		txt.sounds = [
			for (i in 0...10)
				Sound.dialogueSound('sound_scoretally', .3)
		];

		box = new BoxGraphic(x, y, size, speaker, txt, if (feed) 1 else if (cinematic) 2 else 3);
		if (p != null)
		{
			box.y -= box.height;
			box.x = p.x + p.width / 2 - box.width / 2;
		}

		txt.setPosition(box.x + box.width / 2 - txt.width / 2, box.y + (size / 4) + 4);
		txt.text = "";
	}

	public function start():DialogueBox
	{
		if (parentBox != null)
		{
			return parentBox.start();
		}

		box.scale.set(0, 0);
		add(box);
		FlxTween.tween(box.scale, {x: 1, y: 1}, .25, {
			ease: FlxEase.backOut,
			onComplete: twn ->
			{
				txt.start(true);
				txt.completeCallback = () -> new FlxTimer().start(.75, tmr ->
				{
					FlxTween.tween(box.scale, {x: 0, y: 0}, .25, {
						ease: FlxEase.backIn,
						onComplete: twn ->
						{
							box.kill();
							if (nextBox != null)
							{
								nextBox.parentBox = null;
								nextBox.start();
							}
						}
					});
					FlxTween.tween(txt.scale, {x: 0, y: 0}, .25, {
						ease: FlxEase.backIn,
						onComplete: twn ->
						{
							txt.kill();
						}
					});
				});
			}
		});
		add(txt);
		return this;
	}

	public function chain(newBox:DialogueBox):DialogueBox
	{
		nextBox = newBox;
		newBox.parentBox = this;
		return newBox;
	}

	override public function draw()
	{
		super.draw();
		if (nextBox != null)
			nextBox.draw();
	}

	override public function update(elapsed:Float)
	{
		if (nextBox != null)
			nextBox.update(elapsed);
		super.update(elapsed);
	}
}

class BoxGraphic extends FlxTypedSpriteGroup<FlxSprite>
{
	var spkr:FlxText;

	var bg:FlxUI9SliceSprite;

	override public function new(x:Float = 0, y:Float = 0, size:Int = 32, ?speaker:String = '', txt:FlxTypeText, type:Int)
	{
		var suffix:String = '';
		switch (type)
		{
			case 1:
				suffix = '-feed';
			case 2:
				suffix = '';
			case 3:
				suffix = '-talk';
		}
		super(x, y);
		bg = new FlxUI9SliceSprite(0, 0, 'assets/images/diaslice$suffix.png', new Rectangle(0, 0, txt.width + size, txt.height + (size / 2) + 8),
			[8 * 3, 8 * 3, 15 * 3, 15 * 3]);

		add(bg);

		spkr = new FlxText(0, 0, 0, speaker, 32);
		add(spkr);
		spkr.setPosition(bg.x + 10, bg.y - spkr.height + 10);
		spkr.setBorderStyle(OUTLINE, FlxColor.BLACK, 2, 1);
	}
}
