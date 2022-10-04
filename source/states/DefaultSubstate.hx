package states;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class DefaultSubstate extends FlxSubState
{
	var subCam:FlxCamera;

	var controls(get, null):Controls;

	function get_controls():Controls
		return Setup.controls;

	override function add(ob:FlxBasic):FlxBasic
	{
		super.add(ob);

		ob.cameras = [subCam];
		return (ob);
	}

	var canEsc:Bool = false;

	public function new()
	{
		super();

		subCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		subCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(subCam, false);

		addbg();

		//	FlxG.keys.reset();
		FlxG.state.persistentUpdate = true;
	}

	/**making it a function so you can override it to mask whtever**/
	function addbg()
	{
		bg = new FlxBackdrop(FlxGridOverlay.create(64, 64, 64 * 8, 64 * 8, true, 0xff000000, 0xFF2F2F2F).pixels);
		bg.velocity.set(30, 30);

		bg.alpha = .3;
		add(bg);
	}

	var bg:FlxBackdrop;

	var _t:Float;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		Sound.updateSounds(elapsed);

		if ((_t += elapsed) >= .2)
			canEsc = true;
		FlxG.watch.addQuick('HELLLOOOOOOOOOO', canEsc);
		if (canEsc)
			if (FlxG.keys.justPressed.ESCAPE)
				new FlxTimer().start(.05, tmr -> close());
	}

	var closing:Bool = false;

	override public function close()
	{
		FlxG.log.add("closing");
		FlxG.keys.reset();

		if (closing)
			return;

		closing = true;

		subCam.bgColor = FlxColor.TRANSPARENT;
		forEach(obj ->
		{
			if (!obj.cameras.contains(subCam))
				return;
			if (Std.isOfType(obj, FlxSprite))
				FlxTween.tween(obj, {'alpha': 0}, .5, {ease: FlxEase.smootherStepInOut});

			new FlxTimer().start(.55, tmr -> superClose());
		});

		forEachOfType(FlxTypedGroup, grp ->
		{
			grp.forEach(obj2 ->
			{
				if (Std.isOfType(obj2, FlxSprite))
					FlxTween.tween(obj2, {'alpha': 0}, .5, {ease: FlxEase.smootherStepInOut});
			});
		});
	}

	public function superClose()
	{
		// FlxG.cameras.remove(subCam, true);
		super.close();
	}
}
