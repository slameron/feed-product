package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.DialogueBox;
import objects.MenuItem;

using StringTools;

class MenuState extends FlxState
{
	var barTop:FlxSprite;
	var barBottom:FlxSprite;
	var grpItem:FlxTypedGroup<MenuItem>;
	var grpOptions:FlxTypedGroup<MenuItem>;
	var curSel:Int = -1;

	/**The active menu's group of items. Used to dynamically select stuff**/
	var selectGrp:FlxTypedGroup<MenuItem>;

	var inMenu:Bool = true; // False would mean actively in options.

	var ready:Bool = false;
	var feed:FlxTypeText;
	var wires:FlxSprite;

	override public function create()
	{
		super.create();

		var bg = new FlxSprite().loadGraphic('assets/images/menuroom.png');
		bg.scale.set(4, 4);
		add(bg);
		bg.screenCenter();

		wires = new FlxSprite().loadGraphic('assets/images/wires.png', true, 13, 11);
		wires.animation.add('reg', [0]);
		wires.animation.add('spark', [for (i in 1...12) i], 8, false);
		wires.animation.play("reg");

		add(wires);
		wires.scale.set(4, 4);
		wires.setPosition(404, 160);

		var menuItems:Array<
			{
				label:String,
				?type:String,
				?track:Dynamic,
				?onPress:() -> Void,
				?onLeft:() -> Void,
				?onRight:() -> Void
			}> = [
				{label: 'Start Story', onPress: () -> FlxG.switchState(new PlayState())},
				{
					label: 'Test Dialogue',
					onPress: () -> add(new DialogueBox(FlxG.random.int(0, 100), FlxG.random.int(0, 100), "My Name Is Cleveland Brown
And I Am Proud To Be
Right Back In My Home Town
With My New Family
There's Old Friends & New Friends & Even a Bear
Through Good Times & Bad Times
Its True Love To Share
And So I Found A Place
Where Everyone Will Know
My Happy Mustache Face
This Is The Cleveland Show!", 'speaker', true))
				},
				{label: 'Options'}
			];
		var options:Array<
			{
				label:String,
				?type:String,
				?track:Dynamic,
				?onPress:() -> Void,
				?onLeft:() -> Void,
				?onRight:() -> Void,
				?onChange:Dynamic->Void
			}> = [
				{
					label: "Fullscreen",
					track: "FlxG.fullscreen",
					onPress: () ->
					{
						FlxG.fullscreen = !FlxG.fullscreen;
						FlxG.save.data.fullscreen = FlxG.fullscreen;
					}
				},
				{
					label: "Master Volume",
					onLeft: () ->
					{
						FlxG.save.data.volume = FlxMath.roundDecimal(FlxMath.bound(FlxG.save.data.volume - .1, 0, 1), 1);
						FlxG.sound.volume = FlxG.save.data.volume;
						// FlxG.sound.changeVolume(-.1);
					},
					onRight: () ->
					{
						FlxG.save.data.volume = FlxMath.roundDecimal(FlxMath.bound(FlxG.save.data.volume + .1, 0, 1), 1);
						FlxG.sound.volume = FlxG.save.data.volume;
						// FlxG.sound.changeVolume(.1);
					},
					track: "FlxG.sound.volume"
				}, /*
					{
						label: "Sound Volume",
						onLeft: () -> FlxG.save.data.sndVol = FlxMath.roundDecimal(FlxMath.bound(FlxG.save.data.sndVol - .1, 0, 1), 1),
						onRight: () -> FlxG.save.data.sndVol = FlxMath.roundDecimal(FlxMath.bound(FlxG.save.data.sndVol + .1, 0, 1), 1),
						track: "FlxG.save.data.sndVol"
					},
					{
						label: "Music Volume",
						onLeft: () -> FlxG.save.data.musVol = FlxMath.roundDecimal(FlxMath.bound(FlxG.save.data.musVol - .1, 0, 1), 1),
						onRight: () -> FlxG.save.data.musVol = FlxMath.roundDecimal(FlxMath.bound(FlxG.save.data.musVol + .1, 0, 1), 1),
						track: "FlxG.save.data.musVol"
					},
				 */
				{
					label: 'Go back'
				}
			];

		FlxAssets.FONT_DEFAULT = 'assets/fonts/osd_vcr.ttf';

		bgColor = FlxColor.GRAY;

		barTop = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height / 8), FlxColor.BLACK);
		barBottom = new FlxSprite(0, FlxG.height - FlxG.height / 8).makeGraphic(FlxG.width, Std.int(FlxG.height / 8), FlxColor.BLACK);

		feed = new FlxTypeText(0, 0, 0, "FEED", 64);
		feed.cursorCharacter = '_';
		feed.showCursor = true;
		feed.eraseDelay = feed.delay = .1;
		feed.setTypingVariation(.05, true);
		feed.completeCallback = () -> feed.paused = true;
		feed.setPosition(20, (FlxG.height / 2) - feed.height - 30);
		feed.setBorderStyle(SHADOW, FlxColor.BLACK, 4, 1);
		add(feed);

		grpItem = new FlxTypedGroup();
		add(grpItem);
		grpOptions = new FlxTypedGroup();
		add(grpOptions);
		selectGrp = grpItem;

		for (i in 0...menuItems.length)
		{
			var data = menuItems[i];
			var txt = new MenuItem(20, feed.y + feed.height + (22 * i), 0, data.label, 24);
			grpItem.add(txt);
			txt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2, 1);

			txt.ID = i;

			if (data.onPress != null)
				txt.onInteract = data.onPress;
			if (data.onLeft != null)
				txt.onLeft = data.onLeft;
			if (data.onRight != null)
				txt.onRight = data.onRight;
			if (data.track != null)
				txt.track = data.track;
			if (txt.text == 'Options')
				txt.onInteract = gotoOptions;

			var curX = txt.x;
			txt.x = 0 - txt.width - 1;
			FlxTween.tween(txt, {x: curX}, .65, {
				ease: FlxEase.cubeOut,
				startDelay: (i + 1) * .3,
				onComplete: twn -> if (i == menuItems.length - 1)
				{
					ready = true;
					feed.start();
				}
			});
		}
		for (i in 0...options.length)
		{
			var data = options[i];
			var txt = new MenuItem(20, feed.y + feed.height + (22 * i), 0, data.label, 24);
			grpOptions.add(txt);
			txt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2, 1);
			txt.ID = i;

			if (data.onPress != null)
				txt.onInteract = data.onPress;
			if (data.onLeft != null)
				txt.onLeft = data.onLeft;
			if (data.onRight != null)
				txt.onRight = data.onRight;
			if (data.track != null)
				txt.track = data.track;
			if (txt.text == 'Go back')
				txt.onInteract = gotoMenu;

			txt.update(0);

			var curX = txt.x;
			txt.x = 0 - txt.width - 1;
		}

		add(barTop);
		add(barBottom);
	}

	var recentMouse:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		@:privateAccess
		FlxG.watch.addQuick('text', feed._finalText);
		FlxG.watch.addQuick('ready', ready);
		FlxG.watch.addQuick('cursel', curSel);

		if (FlxG.random.bool(.25))
			wires.animation.play('spark');

		if (!ready)
			return;

		var itemsSelected:Int = 0;
		selectGrp.forEach(txt ->
		{
			if (FlxG.mouse.overlaps(txt))
			{
				curSel = txt.ID;
				itemsSelected++;
				recentMouse = true;
			}
		});
		if (itemsSelected > 1 || (itemsSelected == 0 && recentMouse))
			curSel = -1;

		if (itemsSelected == 1 && FlxG.mouse.justPressed)
			select();
		selectGrp.forEach(txt ->
		{
			txt.color = FlxColor.WHITE;
			txt.x = 20;
			if (curSel == txt.ID)
			{
				txt.color = FlxColor.YELLOW;
				txt.x = 25;
			}
		});

		if (FlxG.keys.anyJustPressed([S, DOWN]))
			change(1);
		if (FlxG.keys.anyJustPressed([W, UP]))
			change(-1);
		if (FlxG.keys.anyJustPressed([SPACE, ENTER]))
			select();

		if (curSel >= 0 && curSel < selectGrp.members.length)
		{
			if (FlxG.keys.anyJustPressed([LEFT, A]))
				selectGrp.members[curSel].change(true);

			if (FlxG.keys.anyJustPressed([RIGHT, D]))
				selectGrp.members[curSel].change();
		}
	}

	function change(amt:Int)
	{
		recentMouse = false;
		curSel += amt;
		if (curSel > selectGrp.members.length - 1)
			curSel = 0;
		else if (curSel < 0)
			curSel = selectGrp.members.length - 1;

		FlxG.sound.play(Assets.sound('menuChange'));
	}

	function gotoMenu()
	{
		ready = false;
		updateTitle('feed');
		inMenu = true;
		curSel = -1;

		for (i in 0...grpOptions.members.length)
			FlxTween.tween(grpOptions.members[i], {x: 0 - grpOptions.members[i].width - 1}, .5, {ease: FlxEase.cubeIn, startDelay: .3 * i});
		for (i in 0...grpItem.members.length)
		{
			grpItem.members[i].x = 0 - grpItem.members[i].width - 1;
			FlxTween.tween(grpItem.members[i], {x: 20}, .5, {
				ease: FlxEase.cubeOut,
				startDelay: (.3 * i) + .8,
				onComplete: twn -> if (i == grpItem.members.length - 1)
				{
					ready = true;
					selectGrp = grpItem;
				}
			});
		}
	}

	function gotoOptions()
	{
		ready = false;
		updateTitle('options');
		inMenu = false;
		curSel = -1;

		for (i in 0...grpItem.members.length)
			FlxTween.tween(grpItem.members[i], {x: 0 - grpItem.members[i].width - 1}, .5, {ease: FlxEase.cubeIn, startDelay: .3 * i});
		for (i in 0...grpOptions.members.length)
		{
			grpOptions.members[i].x = 0 - grpOptions.members[i].width - 1;
			FlxTween.tween(grpOptions.members[i], {x: 20}, .5, {
				ease: FlxEase.cubeOut,
				startDelay: (.3 * i) + .8,
				onComplete: twn -> if (i == grpOptions.members.length - 1)
				{
					ready = true;
					selectGrp = grpOptions;
				}
			});
		}
	}

	function updateTitle(title:String)
	{
		feed.erase(null, false, null, () ->
		{
			feed.resetText(title.toUpperCase());
			feed.start();
		});
	}

	function select()
	{
		if (curSel >= selectGrp.members.length || curSel < 0)
			return;

		var curItem = selectGrp.members[curSel];
		curItem.press();
	}
}
