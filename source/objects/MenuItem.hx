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
