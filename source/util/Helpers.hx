package util;

import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef Frame =
{
	animation:String,
	index:Int,
	looped:Bool,
	flipX:Bool
}

typedef AnimationData =
{
	animation:String,
	indices:Array<Int>,
	looped:Bool,
	flipX:Bool
}

class Helpers
{
	/**Take a string and return a bool from it, true or false. WARNING: returns true by default! If it does, make sure to check your spelling.**/
	public static function boolFromString(string:String):Bool
	{
		var daBool:Bool = true;
		switch (string)
		{
			case 'false':
				daBool = false;
			case 'true':
				daBool = true;
		}

		return (daBool);
	}

	/**The loader will check this map for the `char` that is passed in. If not, it defaults to Pickle Frickle's.
		Note that this was for another game I'm just leaving the pickle shit
	**/
	static var runFramerates:Map<String, Int> = ["Pickle Frickle" => 10, "Fire Pickle" => 24];

	static function loadCharacterJson(json:String, ?frames:Bool = true):Array<Dynamic>
	{
		var frameData = cast Json.parse(json).frames;

		return (frameData);
	}

	static function getMetadata(json:String):Dynamic
	{
		var meta = cast Json.parse(json).meta;

		return (meta);
	}

	static function parseFrame(frame:Dynamic, _spritesheetWidth:Int, ?defLoop:Bool = true):Frame
	{
		var framePoint = frame.frame;
		var animName:String = frame.filename;

		var loop:Bool = defLoop;
		var flip:Bool = false;

		var split:Array<String> = animName.split('-');
		for (string in split)
			string = string.trim();

		animName = split[0];

		if (split[1] != null && split[1] != '' && split[1] != " ")
		{
			var param:Array<String> = split[1].split('=');
			// trace(param);
			for (parameter in param)
				parameter = parameter.trim();

			if (param[1] != null)
			{
				// trace(param[0] + ', ' + param[1]);
				// The parameter from the Aseprite tag
				switch (param[0].toLowerCase())
				{
					case 'looped':
						loop = Helpers.boolFromString(param[1]);
					case 'flipx':
						flip = Helpers.boolFromString(param[1]);
				}
			}
		}

		var parsedFrame:Frame = {
			animation: animName,
			index: Std.int((framePoint.x / 32) + ((framePoint.y / 32) * (_spritesheetWidth / 32))),
			looped: loop,
			flipX: flip
		};

		return (parsedFrame);
	}

	/**Usage: var sprite = Helpers.retChar('character', true);
		Default properties of animations:
		Looped: Same as `defLoop`, unless you have `-looped=bool` in Aseprite tags.
		FlipX: False, unless you have `-flipx=bool` in Aseprite tags.
		@param char The filename of the image you want loaded. Relative to `assets/images/characters/`. Note that in FNF project it probably has to be under preload folder.
		@param defLoop Whether the animations should loop by default, being overridden by `-looped=bool` in the Aseprite tag. Defaults to true.

	**/
	public static function retChar(char:String, ?defLoop:Bool = true):FlxSprite
	{
		// the character to return
		var c = new FlxSprite();
		c.setFacingFlip(LEFT, true, false);
		c.setFacingFlip(RIGHT, false, false);
		c.facing = RIGHT;
		c.loadGraphic('assets/images/characters/$char.png', true, 32, 32);
		if (openfl.utils.Assets.exists('assets/images/characters/$char.json', TEXT))
		{
			var json:String = Assets.getText('assets/images/characters/$char.json').trim();
			var frameInfo:Array<Dynamic> = loadCharacterJson(json);
			var metadata:Dynamic = getMetadata(json);

			var _SSW:Int = metadata.size.w;

			var animationsList:Map<String, AnimationData> = [];

			for (i in 0...frameInfo.length)
			{
				var parsedFrame = parseFrame(frameInfo[i], _SSW, defLoop);

				// it's not a blank frame
				if (parsedFrame.animation != null && parsedFrame.animation != "" && parsedFrame.animation != " ")
				{
					// the map already has the animation
					if (animationsList.exists(parsedFrame.animation))
					{
						animationsList[parsedFrame.animation].indices.push(parsedFrame.index);
					}
					// the map doesn't have this anim yet
					else
					{
						var animationData:AnimationData = {
							animation: parsedFrame.animation,
							indices: [parsedFrame.index],
							looped: parsedFrame.looped,
							flipX: parsedFrame.flipX
						};
						animationsList.set(parsedFrame.animation, animationData);
					}
				}
			}

			json = null;
			frameInfo = null;
			metadata = null;

			var framerate:Int = 0;

			if (runFramerates.exists(char))
				framerate = runFramerates[char];
			else
				framerate = runFramerates['Pickle Frickle'];

			for (key in animationsList.keys())
				c.animation.add(key, animationsList[key].indices, framerate, animationsList[key].looped, animationsList[key].flipX);

			// trace(animationsList);
		}
		else
		{
			trace('Didn\'t find an animation json for $char. Make sure to export it in Aseprite');
			// playAnims = false;
		}

		// trace(Std.isOfType(c, FlxSprite) + 'its a flxsptite');
		return c;
	}
}
