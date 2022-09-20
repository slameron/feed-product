package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.text.FlxTypeText;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;

class Setup extends FlxState
{
	var days = [
		'Sunday',
		'Monday',
		'Tuesday',
		'Wednesday',
		'Thursday',
		'Friday',
		'Saturday',
		'Sunday'
	];

	override public function create()
	{
		super.create();

		FlxG.save.bind('FEED_PRODUCT');
		FlxG.autoPause = false;
		FlxG.mouse.useSystemCursor = true;

		FlxAssets.FONT_DEFAULT = #if desktop 'assets/fonts/mc.ttf' #else 'assets/fonts/osd_vcr.ttf' #end;

		if (FlxG.save.data.musVol == null)
			FlxG.save.data.musVol = 1;
		if (FlxG.save.data.sndVol == null)
			FlxG.save.data.sndVol = 1;
		if (FlxG.save.data.mastVol == null)
			FlxG.save.data.mastVol = 1;

		if (FlxG.save.data.fullscreen != null)
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		FlxG.save.flush();

		FlxG.sound.playMusic(Assets.music('24hr'), .2);

		var txt = 'starting feedOS...
		welcome user
		it\'s ${days[Date.now().getDay()]}.
		connecting to internet...';

		var coolText = new FlxTypeText(0, 0, FlxG.width, txt, 32);
		coolText.useDefaultSound = false;
		coolText.finishSounds = true;
		coolText.cursorCharacter = '_';
		coolText.showCursor = true;
		coolText.eraseDelay = coolText.delay = .1;
		coolText.setTypingVariation(.05, true);
		coolText.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);
		coolText.sounds = [
			for (i in 0...30)
				new FlxSound().loadEmbedded(Assets.sound('menuChange'))
		];
		coolText.start(true);
		add(coolText);
		coolText.completeCallback = () -> new FlxTimer().start(3, tmr -> FlxG.switchState(new states.MenuState()));
	}
}
