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
	var bg:FlxUI9SliceSprite;
	var txt:FlxTypeText;
	var spkr:FlxText;

	override public function new(x:Float = 0, y:Float = 0, text:String = '', size:Int = 32, ?speaker:String, cinematic:Bool = false)
	{
		super();

		var fieldW:Int = Std.int(FlxG.width - x - FlxG.random.int(30, 80));
		if (cinematic)
		{
			size = 32;
			x = 50;

			fieldW = Std.int(FlxG.width - 100);
		}
		fieldW -= size;
		txt = new FlxTypeText(x + (size / 2), y + (size / 4) + 4, fieldW, text, size);
		txt.text = text;
		if (cinematic)
		{
			y = FlxG.height - txt.height - size - 10;
			txt.y = y + (size / 4) + 5;
		}
		txt.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);
		txt.useDefaultSound = false;
		txt.finishSounds = true;
		txt.sounds = [
			for (i in 0...10)
				new FlxSound().loadEmbedded(Assets.sound('sound_scoretally', '.wav'))
		];
		bg = new FlxUI9SliceSprite(x, y, 'assets/images/diaslice.png', new Rectangle(0, 0, txt.width + size, txt.height + (size / 2) + 8),
			[8 * 3, 8 * 3, 15 * 3, 15 * 3]);
		txt.setPosition(bg.x + bg.width / 2 - txt.width / 2, bg.y + bg.height / 2 - txt.height / 2);
		txt.text = "";

		add(bg);

		bg.scale.set(0, 0);
		FlxTween.tween(bg.scale, {x: 1, y: 1}, .25, {
			ease: FlxEase.backOut,
			onComplete: twn ->
			{
				txt.start(true);
				txt.completeCallback = () -> new FlxTimer().start(2, tmr ->
				{
					FlxTween.tween(bg.scale, {x: 0, y: 0}, .25, {ease: FlxEase.backIn, onComplete: twn -> bg.kill()});
					FlxTween.tween(txt.scale, {x: 0, y: 0}, .25, {ease: FlxEase.backIn, onComplete: twn -> txt.kill()});
				});
			}
		});
		add(txt);
	}
}
