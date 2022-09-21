package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.text.FlxTypeText;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import openfl.filters.ShaderFilter;

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

	override public function create()
	{
		super.create();

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
		FlxG.save.flush();

		Sound.playMusic('24hr', .1);

		var http = new haxe.Http('https://ipinfo.io/json'); // get the coords

		http.onData = function(data:Dynamic)
		{
			var json = haxe.Json.parse(data);

			trace(json.loc);
			if (json.loc == null)
			{
				connectionlessText = 'internet connection failed. please check your hardware and try again later.';
				setupTxt();
				trace('json.loc is null or somethi...');
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
				trace(json);

				weatherID = json.daily.weathercode[0];
				trace('weatherID $weatherID');
				setupTxt();
			}
			http2.onError = function(error)
			{
				connectionlessText = 'internet connection failed. please check your hardware and try again later.';
				setupTxt();
			}
			http2.request();
		}

		http.onError = function(error)
		{
			connectionlessText = 'internet connection failed. please check your hardware and try again later.';
			setupTxt();
		}

		http.request();
	}

	var connectionlessText = '';

	function setupTxt()
	{
		var txt = 'starting feedOS...          
		connecting to the internet...          ${connectionlessText != '' ? '\n' + connectionlessText : ''}
		it\'s ${days[Date.now().getDay()]}. ${weatherType()} ${weatherComment()}
		welcome user
		
		';

		var coolText = new FlxTypeText(0, 0, FlxG.width, txt, 32);
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
		coolText.completeCallback = () -> new FlxTimer().start(3, tmr -> FlxG.switchState(new states.MenuState()));
		add(coolText);
	}

	var weatherID:Int = -1;
	var weatherMap:Map<Int, {type:String, comment:String}> = [
		0 => {type: "the skies are clear.", comment: ""},
		1 => {type: "the skies are clear.", comment: ""},
		2 => {type: "the skies are clear.", comment: ""},
		3 => {type: "the skies are clear.", comment: ""},
		45 => {type: "the skies are clear.", comment: ""},
		48 => {type: "the skies are clear.", comment: ""},
		51 => {type: "the skies are clear.", comment: ""},
		53 => {type: "the skies are clear.", comment: ""},
		55 => {type: "the skies are clear.", comment: ""},
		56 => {type: "the skies are clear.", comment: ""},
		57 => {type: "the skies are clear.", comment: ""},
		61 => {type: "the skies are clear.", comment: ""},
		63 => {type: "the skies are clear.", comment: ""},
		65 => {type: "the skies are clear.", comment: ""},
		66 => {type: "the skies are clear.", comment: ""},
		67 => {type: "the skies are clear.", comment: ""},
		71 => {type: "the skies are clear.", comment: ""},
		73 => {type: "the skies are clear.", comment: ""},
		75 => {type: "the skies are clear.", comment: ""},
		77 => {type: "the skies are clear.", comment: ""},
		80 => {type: "the skies are clear.", comment: ""},
		81 => {type: "the skies are clear.", comment: ""},
		82 => {type: "the skies are clear.", comment: ""},
		85 => {type: "the skies are clear.", comment: ""},
		86 => {type: "the skies are clear.", comment: ""},
		95 => {type: "the skies are clear.", comment: ""},
		96 => {type: "the skies are clear.", comment: ""},
		99 => {type: "the skies are clear.", comment: ""}
	];

	function weatherType():String
		return weatherID == -1 ? '' : weatherMap[weatherID].type;

	function weatherComment():String
		return weatherID == -1 ? '' : weatherMap[weatherID].comment;
}
