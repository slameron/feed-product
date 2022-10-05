package objects;

import util.Text;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.text.FlxText; #if hscript import flixel.system.debug.console.ConsoleUtil; #end

class MenuItem extends Text
{
	public var onInteract:() -> Void;
	public var onLeft:() -> Void;
	public var onRight:() -> Void;
	public var track:String;
	public var clipSpr:FlxSprite;

	/**if true, `clipSpr` will be calculated from the left, otherwise it does it from the right**/
	public var clipLeft:Bool = false;

	/**What the text was before being modified by code**/
	public var sourceText:String;

	override function set_text(text:String):String
	{
		super.set_text(text);
		if (sourceText == null)
			sourceText = text;
		return (text);
	}

	public function press()
	{
		if (onInteract != null)
		{
			onInteract();
			Sound.play('menuSelect');
		}

		FlxG.save.flush();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (track != null)
		{
			var parsedExpr:Dynamic;
			#if hscript
			parsedExpr = ConsoleUtil.runExpr(ConsoleUtil.parseCommand(track));

			if (Std.isOfType(parsedExpr, Float))
				parsedExpr = FlxMath.roundDecimal(parsedExpr, 1);

			text = '$sourceText ${onLeft != null ? '< ${Std.string(parsedExpr)} >' : Std.string(parsedExpr)}';
			#end
		}

		FlxG.watch.addQuick('infos', 'clipRect: $clipRect, clipLeft: $clipLeft, clipSpr: $clipSpr');
		if (clipSpr != null)
		{
			if (clipLeft)
			{
				if (x + width >= clipSpr.x + clipSpr.width / 2)
				{
					var daW = (x + width) - (clipSpr.x + clipSpr.width / 2);
					daW = FlxMath.bound(daW, 0, width);
					var rect:FlxRect = new FlxRect(0, 0, width - daW, height);
					clipRect = rect;
				}
				else
					clipRect = null;
			}
			else if (x <= clipSpr.x + clipSpr.width / 2)
			{
				var daW = (clipSpr.x + clipSpr.width / 2) - x;
				daW = FlxMath.bound(daW, 0, width);
				var rect:FlxRect = new FlxRect(width - (width - daW), 0, width - daW, height);
				clipRect = rect;
			}
			else
				clipRect = null;
		}
	}

	public function change(left:Bool = false)
	{
		if (left)
			if (onLeft != null)
			{
				onLeft();
				Sound.play('menuChange');
			}

		if (!left)
			if (onRight != null)
			{
				onRight();
				Sound.play('menuChange');
			}

		FlxG.save.flush();
	}
}
