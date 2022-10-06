package states;

import flixel.FlxCamera;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.system.debug.console.ConsoleUtil;
import flixel.tile.FlxTilemap;
import flixel.util.FlxCollision;
import hscript.Interp;
import hscript.Parser;

class DefaultState extends FlxTransitionableState
{
	var loader:FlxOgmo3Loader;
	var interactables:FlxTypedGroup<Interactable>;
	var player:Player;

	override public function new(?level:String)
	{
		super();
		this.level = level;
	}

	override public function create()
	{
		super.create();

		interactables = new FlxTypedGroup();

		if (level != null)
			player = new Player(0, 0, 4); // make sure it exists before setting position via loading entities

		if (level != null)
			loadTilemap();

		add(interactables);

		if (level != null)
		{
			add(player);

			player.addCollision(tiles, false);

			FlxG.camera.follow(player, PLATFORMER, 0.2);
		}
	}

	function loadTilemap()
	{
		loader = new FlxOgmo3Loader('assets/data/feed.ogmo', 'assets/data/levels/$level.json');
		@:privateAccess
		tiles = loader.loadTilemap(StringTools.replace(FlxOgmo3Loader.getTilesetData(loader.project,
			FlxOgmo3Loader.getTileLayer(loader.level, 'ground').tileset)
			.path, "..", "assets"),
			'ground');
		add(tiles);
		tiles.setTileProperties(0, NONE, null, null, 2);
		tiles.setTileProperties(2, ANY);
		tiles.setTileProperties(3, NONE);
		@:privateAccess
		if (tiles._tileObjects.length >= 8)
			tiles.setTileProperties(8, ANY, null, null, 4);

		loadEnts();
		tiles.follow(FlxG.camera, 0, true);
	}

	var level:String = null;
	var tiles:FlxTilemap;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Sound.updateSounds(elapsed);

		if (FlxG.keys.justPressed.ESCAPE && !Std.isOfType(FlxG.state, MenuState) && subState != null)
			openSubState(new PauseSubstate());

		if (interactables.members.length > 0)
			interactables.forEach(item -> if (item != null) item.beingHovered = false);

		if (player == null)
			return;

		player.hoveringSomething = false;
		FlxG.overlap(player, interactables, (obj1:Player, obj2:Interactable) ->
		{
			if (obj1.hoveringSomething || obj1.inCutscene || obj2.onInteract == null)
				return;

			obj1.hoveringSomething = true;

			obj2.beingHovered = true;
			if (obj1.controls.interact)
				obj2.onInteract(obj1);
		});
	}

	/**returns the asset path for the provided entity in Ogmo. 
		@param entName The name of the entity in Ogmo. Pass this in as it appears in Ogmo.**/
	function getEntityGraphic(entName:String):String
	{
		var projectdata = haxe.Json.parse(lime.utils.Assets.getText('assets/data/${loader.project.name}.ogmo'));

		var path:String = '';

		var entities:Array<Dynamic> = projectdata.entities;

		for (entity in projectdata.entities)
			if (entity.name == entName)
				path = StringTools.replace(entity.texture, '..', 'assets');

		return path;
	}

	function makeStars()
	{
		var amt = 500;
		var time = 5;
		bgColor = FlxColor.BLACK;
		var coolSplash:FlxEmitter = new FlxEmitter(FlxG.width / 2, FlxG.height / 2, amt);
		coolSplash.makeParticles(2, 2, FlxColor.WHITE, amt);
		coolSplash.alpha.set(.1, .7, .1, .7);
		coolSplash.lifespan.set(time + .5);
		coolSplash.speed.set(0, FlxG.width / time, 0, 0);
		insert(0, coolSplash);
		coolSplash.active = false;

		coolSplash.start(false, time / amt);
		coolSplash.update(time);
	}

	function loadEnts()
	{
		loader.loadEntities(e ->
		{
			switch (e.name)
			{
				case 'player': player.setPosition(e.x, e.y + 500);
				case 'stars': makeStars();
				case 'daShip':
					var ship = new Interactable(0, 0, 'assets/images/upcar-old.png', null, true, 32, 16);
					var s = e.width / ship.width;
					ship.scale.set(s, s);
					ship.updateHitbox();
					ship.setPosition(e.x, e.y);
					ship.onInteract = spr ->
					{
						spr.visible = false;
						cast(spr, Player).inCutscene = true;
						ship.animation.play('occ');
						new FlxTimer().start(3, tmr -> FlxTween.tween(ship, {y: ship.y - 1000}, 2, {onComplete: twn -> FlxG.switchState(new SpaceStation())}));
					};
					ship.animation.add('empty', [0]);
					ship.animation.add('occ', [1]);
					ship.animation.play('empty');

					interactables.add(ship);

				default:
					interactables.add(new Interactable(e.x, e.y, getEntityGraphic(e.name), spr ->
					{
						if (e.values.SwitchState == true)
						{
							switch (e.values.State)
							{
								case "SpaceStation": FlxG.switchState(new SpaceStation());
								case "DefaultState": if (e.values.LevelPath != null) FlxG.switchState(new DefaultState(e.values.LevelPath));
								case "PlayState": FlxG.switchState(new PlayState('house'));
								case "RicochetLounge-Outside":
									if (Std.isOfType(FlxG.state, RicochetLounge))
										FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
									FlxG.switchState(new RicochetLounge(false));
								case "RicochetLounge-Inside":
									if (Std.isOfType(FlxG.state, RicochetLounge))
										FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
									FlxG.switchState(new RicochetLounge(true));
							}
						}
						else // This will need to undergo way more testing, i have no idea why this doesn't work
						{
							var func = ConsoleUtil.runExpr(ConsoleUtil.parseCommand('spr -> {${e.values.OnInteract}}'));
							trace(func);
							func(spr);
						}
					}));
			}
		}, 'ents_fg');
	}
}
