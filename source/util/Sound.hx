package util;

import flixel.FlxObject;
import flixel.system.FlxSound;

class CustomMus extends FlxSound
{
	/**just the original volume before mapped to three channels**/
	public var normal:Float = 1;
}

class Sound
{
	public static var panRadius:Float = 150;

	static var sounds:Array<CustomMus> = [];
	static var musics:Map<String, CustomMus> = [];

	public static var menuMusic:FlxSound;
	public static var gameMus:FlxSound;

	public static function play(key:String, vol:Float = 1, ?source:FlxObject, ?playa:FlxObject):CustomMus
	{
		var newSound:CustomMus = new CustomMus();
		newSound.loadEmbedded(RetPath.sound(key));
		newSound.volume = vol * FlxG.save.data.sndVol * FlxG.sound.volume;
		if (key == 'fire_shotgun')
			newSound.volume *= .4;

		if (source != null)
			newSound.proximity(source.x + source.width / 2, source.y + source.height / 2, playa, panRadius, true);

		newSound.autoDestroy = true;
		newSound.onComplete = () -> sounds.remove(newSound);
		newSound.play();
		newSound.update(0);

		sounds.push(newSound);

		return newSound;
	}

	public static function dialogueSound(key:String, vol:Float = 1, extension:String = '.wav'):CustomMus
	{
		var newSound:CustomMus = new CustomMus();
		newSound.loadEmbedded(Assets.sound(key, extension));
		newSound.volume = vol * FlxG.save.data.sndVol * FlxG.sound.volume;

		return newSound;
	}

	public static function playMusic(key:String, vol:Float = 1, persist:Bool = true, outside:Bool = false, restart:Bool = true):CustomMus
	{
		stopMusic();
		if (musics.get(key) != null)
		{
			musics.get(key).play(restart);
			return musics.get(key);
		}
		var newSound:CustomMus = new CustomMus();
		newSound.loadEmbedded(RetPath.music(key), true);
		newSound.normal = vol;
		newSound.volume = 0; // make sure it doesnt peak at first before update
		newSound.play();
		newSound.update(0);
		newSound.persist = persist;

		musics.set(key, newSound);
		if (outside)
		{
			var newSound2:CustomMus = new CustomMus();
			newSound2.loadEmbedded(RetPath.music('$key-outside'), true);
			newSound2.normal = vol;
			newSound2.volume = 0; // make sure it doesnt peak at first before update
			newSound2.play();
			newSound2.pause();
			newSound2.update(0);
			newSound2.persist = persist;
			musics.set('$key-outside', newSound2);
		}

		return newSound;
	}

	public static function swapOutside(key:String, ?forceOutside:Bool, ?volume:Float)
	{
		stopMusic(key, true);
		if (musics.get(key) == null)
			playMusic(key, volume != null ? volume : 1, true, true);

		if (forceOutside)
		{
			musics.get('$key-outside').resume();
			musics.get('$key-outside').time = musics.get(key).time;

			musics.get('$key').pause();
		}
		else
		{
			if (musics.get('$key-outside').playing)
			{
				musics.get('$key-outside').pause();
				musics.get('$key').resume();
				musics.get('$key').time = musics.get('$key-outside').time;
			}
			else
			{
				musics.get('$key-outside').resume();
				musics.get('$key').pause();
				musics.get('$key-outside').time = musics.get('$key').time;
			}
		}
	}

	public static function stopMusic(?exception:String, outside:Bool = false)
	{
		for (music in musics)
		{
			if (exception != null)
			{
				if (musics.get(exception) == music)
					continue;

				if (outside)
					if (musics.get('$exception-outside') == music)
						continue;
			}
			if (music.playing)
				music.pause();
		}
	}

	public static function updateSounds(elapsed:Float)
	{
		for (sound in sounds)
			sound.update(elapsed);

		for (sound in musics.keys())
			if (musics[sound] != null)
			{
				musics[sound].update(elapsed);
				musics[sound].volume = FlxMath.lerp(musics[sound].volume, musics[sound].normal * FlxG.save.data.musVol * FlxG.sound.volume, .2);
			}
			else
				musics.remove(sound);
	}
}
