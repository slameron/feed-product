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

	public static function playMusic(key:String, vol:Float = 1, persist:Bool = true):CustomMus
	{
		var newSound:CustomMus = new CustomMus();
		newSound.loadEmbedded(RetPath.music(key), true);
		newSound.normal = vol;
		newSound.play();
		newSound.update(0);
		newSound.persist = persist;

		musics.set(key, newSound);

		return newSound;
	}

	public static function updateSounds(elapsed:Float)
	{
		for (sound in sounds)
			sound.update(elapsed);

		for (sound in musics.keys())
			if (musics[sound] != null)
			{
				musics[sound].update(elapsed);
				musics[sound].volume = musics[sound].normal * FlxG.save.data.musVol * FlxG.sound.volume;
			}
			else
				musics.remove(sound);
	}
}
