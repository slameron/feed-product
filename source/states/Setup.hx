package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.text.FlxTypeText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import lime.app.Application;
import openfl.display3D.textures.Texture;
import openfl.filters.ShaderFilter;
import vfx.CrtShader;

class Setup extends DefaultState
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

	var timeslots = ['morning', 'afternoon', 'evening', 'night'];

	public static var controls(get, null):Controls;

	static function get_controls():Controls
	{
		controls.update(FlxG.elapsed);
		return controls;
	}

	override public function create()
	{
		super.create();
		controls = new Controls();

		FlxTransitionableState.defaultTransIn = new TransitionData(TransitionType.TILES, FlxColor.BLACK, .25, new FlxPoint(1, 1));
		FlxTransitionableState.defaultTransOut = FlxTransitionableState.defaultTransIn;

		FlxG.save.bind('FEED_PRODUCT');
		FlxG.log.redirectTraces = true;
		FlxG.autoPause = false;
		FlxG.mouse.useSystemCursor = true;

		FlxAssets.FONT_DEFAULT = #if desktop 'assets/fonts/mc.ttf' #else 'assets/fonts/osd_vcr.ttf' #end;

		if (FlxG.save.data.musVol == null)
			FlxG.save.data.musVol = .5;
		if (FlxG.save.data.sndVol == null)
			FlxG.save.data.sndVol = 1;

		if (FlxG.save.data.fullscreen != null)
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		else
			FlxG.fullscreen = FlxG.save.data.fullscreen = true;
		FlxG.save.flush();

		Sound.playMusic('poison2', .1);

		var http = new haxe.Http('https://ipinfo.io/json'); // get the coords

		http.onData = function(data:Dynamic)
		{
			var json = haxe.Json.parse(data);

			if (json.loc == null)
			{
				connectionlessText = 'feednet connection failed. please check your network connection and try again later.';
				setupTxt();

				return;
			}
			var loc:String = json.loc;
			var geolocation:Array<String> = loc.split(',');
			for (i in geolocation)
				i = StringTools.trim(i);
			var http2 = new haxe.Http('https://api.open-meteo.com/v1/forecast?latitude=${geolocation[0]}&longitude=${geolocation[1]}&daily=weathercode&timezone=America%2FNew_York'); // get the weather forecast
			http2.onData = function(data:Dynamic)
			{
				var json = haxe.Json.parse(data);

				weatherID = json.daily.weathercode[0];

				setupTxt();
			}
			http2.onError = function(error)
			{
				connectionlessText = 'feednet connection failed. please check your network connection and try again later.';
				setupTxt();
			}
			http2.request();
		}

		http.onError = function(error)
		{
			connectionlessText = 'feednet connection failed. please check your network connection and try again later.';
			setupTxt();
		}

		http.request();

		vcrGrp = new FlxTypedGroup();
		add(vcrGrp);
		for (i in 0...FlxG.height + 8) // +8 to ensure an extra line gets added, otherwise there may be a small gap
		{
			if (i % 8 != 0)
				continue;

			var vcrLine = new FlxSprite().makeGraphic(FlxG.width, 1, FlxColor.BLACK);
			vcrGrp.add(vcrLine);
			vcrLine.y = i;
			vcrLine.velocity.y = 5;
		}

		FlxG.game.setFilters([new ShaderFilter(new CrtShader())]);
	}

	var vcrGrp:FlxTypedGroup<FlxSprite>;
	var connectionlessText = '';

	function setupTxt()
	{
		var txt = 'starting feedOS v${Application.current.meta.get('version')}...          
		connecting to the feed...          ${connectionlessText != '' ? '\n' + connectionlessText : ''}
		good ${timeSlot()}. it\'s ${days[Date.now().getDay()]}. ${weatherType()} ${weatherComment()}
		
		welcome user
		
		';

		var coolText = new FlxTypeText(40, 40, FlxG.width - 80, txt, 32);
		coolText.useDefaultSound = false;
		coolText.finishSounds = true;
		coolText.cursorCharacter = '_';
		coolText.showCursor = true;
		coolText.eraseDelay = coolText.delay = .08;
		coolText.setTypingVariation(.05, true);
		coolText.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);
		coolText.sounds = [
			for (i in 0...30)
				new FlxSound().loadEmbedded(Assets.sound('menuChange'))
		];
		coolText.start(true);
		coolText.completeCallback = () -> new FlxTimer().start(3, tmr ->
		{
			FlxG.switchState(new states.MenuState());
			FlxG.game.setFilters([]);
		});
		add(coolText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		vcrGrp.forEach(line ->
		{
			if (line.y >= FlxG.height)
			{
				var diff = line.y - FlxG.height;
				line.y = -1 + diff;
			}
		});

		if (FlxG.keys.justPressed.ANY)
		{
			FlxG.switchState(new states.MenuState());
			FlxG.game.setFilters([]);
		}
	}

	var weatherID:Int = -1;
	var weatherMap:Map<Int, {type:String, comment:String}> = [
		0 => {type: "the skies are clear.", comment: ""},
		1 => {type: "the skies are mostly clear.", comment: ""},
		2 => {type: "it's partly cloudy.", comment: ""},
		3 => {type: "the skies are cast with clouds.", comment: "maybe it'll rain."},
		45 => {type: "it's foggy.", comment: ""},
		48 => {type: "it's foggy.", comment: ""},
		51 => {type: "it's foggy.", comment: ""},
		53 => {type: "it's foggy.", comment: ""},
		55 => {type: "it's foggy.", comment: ""},
		56 => {type: "it's foggy.", comment: ""},
		57 => {type: "it's foggy.", comment: ""},
		61 => {type: "it's raining lightly.", comment: ""},
		63 => {type: "it's raining.", comment: ""},
		65 => {type: "it's raining heavily.", comment: "the sound must be relaxing."},
		66 => {type: "it's raining", comment: "with some ice."},
		67 => {type: "it's raining.", comment: "lots of ice."},
		71 => {type: "it's snowing lightly.", comment: ""},
		73 => {type: "it's snowing.", comment: ""},
		75 => {type: "it's snowing heavily.", comment: ""},
		77 => {type: "it's snowing.", comment: ""},
		80 => {type: "it's raining.", comment: ""},
		81 => {type: "it's raining.", comment: ""},
		82 => {type: "it's raining.", comment: ""},
		85 => {type: "it's snowing.", comment: ""},
		86 => {type: "it's snowing.", comment: ""},
		95 => {type: "it's storming.", comment: ""},
		96 => {type: "it's storming.", comment: ""},
		99 => {type: "it's storming.", comment: ""}
	];

	function weatherType():String
		return weatherID == -1 ? '' : weatherMap[weatherID].type;

	function weatherComment():String
		return weatherID == -1 ? '' : weatherMap[weatherID].comment;

	function timeSlot():String
	{
		var time:String = '';
		switch (Date.now().getHours())
		{
			case 23 | 0 | 1 | 2 | 3 | 4:
				time = timeslots[3];

			case 5 | 6 | 7 | 8 | 9 | 10 | 11:
				time = timeslots[0];

			case 12 | 13 | 14 | 15 | 16 | 17 | 18:
				time = timeslots[1];

			case 19 | 20 | 21 | 22:
				time = timeslots[2];
		}
		return time;
	}
}
