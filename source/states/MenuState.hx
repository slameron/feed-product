package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
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
	var menuItems:Array<
		{
			label:String,
			?type:String,
			?df:Dynamic,
			?onPress:() -> Void
		}> = [
			{label: 'Start Story', onPress: () -> FlxG.switchState(new PlayState())},
			{label: 'Options'}
		];
	var options:Array<
		{
			label:String,
			?type:String,
			?df:Dynamic,
			?onPress:() -> Void
		}> = [
			{
				label: "Fullscreen",
				df: FlxG.fullscreen,
				onPress: () -> FlxG.fullscreen = !FlxG.fullscreen
			},
			{label: 'Go back'}
		];
	var ready:Bool = false;
	var feed:FlxTypeText;

	override public function create()
	{
		super.create();
		FlxAssets.FONT_DEFAULT = 'assets/fonts/pixel.ttf';

		bgColor = FlxColor.GRAY;

		barTop = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height / 8), FlxColor.BLACK);
		barBottom = new FlxSprite(0, FlxG.height - FlxG.height / 8).makeGraphic(FlxG.width, Std.int(FlxG.height / 8), FlxColor.BLACK);

		feed = new FlxTypeText(0, 0, 0, "FEED", 64);
		feed.font = 'assets/fonts/osd_vcr.ttf';
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
			var txt = new MenuItem(20, feed.y - 11 + feed.height + (36 * i), 0, menuItems[i].label, 48);
			grpItem.add(txt);
			txt.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);
			txt.ID = i;

			txt.onInteract = menuItems[i].onPress;
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
			var txt = new MenuItem(20, feed.y - 11 + feed.height + (36 * i), 0, options[i].label, 48);
			grpOptions.add(txt);
			txt.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);
			txt.ID = i;

			txt.onInteract = options[i].onPress;
			if (txt.text == 'Go back')
				txt.onInteract = gotoMenu;

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
	}

	function change(amt:Int)
	{
		recentMouse = false;
		curSel += amt;
		if (curSel > selectGrp.members.length - 1)
			curSel = 0;
		else if (curSel < 0)
			curSel = selectGrp.members.length - 1;
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
		if (curSel >= menuItems.length || curSel < 0)
			return;
		var daSel = curSel;
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
		curItem.onInteract();
	}
}
