package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.text.FlxTypeText;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.DialogueBox;
import objects.MenuItem;
import openfl.display.StageQuality;

using StringTools;

class MenuState extends DefaultState
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
	var sittingMarty:FlxSprite;

	override public function create()
	{
		super.create();

		var loader = new FlxOgmo3Loader('assets/data/feed.ogmo', 'assets/data/levels/house.json');
		@:privateAccess
		var tiles = loader.loadTilemap(StringTools.replace(FlxOgmo3Loader.getTilesetData(loader.project,
			FlxOgmo3Loader.getTileLayer(loader.level, 'ground').tileset)
			.path, "..", "assets"),
			'ground');
		add(tiles);

		wires = new FlxSprite().loadGraphic('assets/images/wires.png', true, 13, 11);
		wires.animation.add('reg', [0]);
		wires.animation.add('spark', [for (i in 1...12) i], 8, false);
		wires.animation.play("reg");

		add(wires);
		wires.scale.set(4, 4);
		wires.updateHitbox();
		wires.setPosition(404, 152 + (9*4));

		var lt = new FlxSprite().loadGraphic('assets/images/titusClear.png', true, 14, 34);
		lt.animation.add('reg', [0]);
		lt.animation.play('reg');
		var w = [5, 4, 3, 4, 5, 6];

		w = w.concat(w);
		lt.animation.add('waft', [for (i in 0...7) i].concat(w).concat([for (i in 0...7) 6 - i]), 8, false);
		lt.scale.set(4, 4);
		lt.updateHitbox();
		lt.setPosition(86 * 4, 27 * 4);
		add(lt);

		sittingMarty = new FlxSprite().loadGraphic('assets/images/martyZap.png', true, 18, 24);
		sittingMarty.animation.add('reg', [0]);
		sittingMarty.animation.add('spark', [for (i in 0...16) 1].concat([for (i in 2...6) i]).concat([for (i in 0...16) (6 + (i % 2))]), 12, false);
		sittingMarty.animation.play("reg");
		sittingMarty.animation.callback = function(name, number, index)
		{
			if (name == 'spark')
				if (number == 20)
					Sound.play('sound_zap', .2);
		};
		sittingMarty.animation.finishCallback = name -> if (name == 'spark')
		{
			sittingMarty.animation.play('reg');
			var emitter:FlxEmitter = new FlxEmitter(sittingMarty.x + (10 * 4), sittingMarty.y + (4 * 4), 30);
			emitter.makeParticles(2, 2, FlxColor.BLACK, 30);
			emitter.scale.set(1, 1, 1, 1, 20, 20, 50, 50);
			emitter.angularVelocity.set(0, 50, 20, 100);
			emitter.alpha.set(0.6, 0.6, 0.0, 0.0);
			emitter.launchMode = SQUARE;
			emitter.velocity.set(-50, -40, 50, -10, -50, -100, 50, -50);
			emitter.start();
			insert(members.indexOf(sittingMarty), emitter);

			new FlxTimer().start(FlxG.random.float(0.5, 1.5), tmr -> lt.animation.play('waft', true));
		};
		add(sittingMarty);

		sittingMarty.scale.set(4, 4);
		sittingMarty.updateHitbox();
		sittingMarty.setPosition(wires.x + 10 * 4, 40 * 4);

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
					onPress: () -> add(new DialogueBox(FlxG.random.int(0, 100), FlxG.random.int(0, 100), "text box", 'speaker', FlxG.random.bool(25),
						FlxG.random.bool(25)))
				},
				{label: 'Options'}
				#if desktop, {label: 'Exit', onPress: () -> Sys.exit(0)} #end
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
				},
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

				{
					label: 'Go back'
				}
			];

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
			var txt = new MenuItem(20, feed.y + feed.height + (22 * i), 0, data.label, 32);
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
			var txt = new MenuItem(20, feed.y + feed.height + (22 * i), 0, data.label, 32);
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

		if (FlxG.random.bool(.1) && sittingMarty.animation.name != 'spark')
			sittingMarty.animation.play('spark');

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

		Sound.play('menuChange');
	}

	function gotoMenu()
	{
		grpItem.forEach(item -> item.color = FlxColor.WHITE);
		grpOptions.forEach(item -> item.color = FlxColor.WHITE);
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
		grpItem.forEach(item -> item.color = FlxColor.WHITE);
		grpOptions.forEach(item -> item.color = FlxColor.WHITE);
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
