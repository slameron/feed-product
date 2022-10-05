package states;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.debug.console.ConsoleUtil;
import flixel.tile.FlxTilemap;
import flixel.util.FlxCollision;
import hscript.Interp;
import hscript.Parser;

class DefaultState extends FlxTransitionableState
{
	var loader:FlxOgmo3Loader;
	var interactables:FlxTypedGroup<Interactable>;

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
			loadTilemap();

		add(interactables);
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
		tiles.setTileProperties(2, ANY, null, null, 1);
		tiles.setTileProperties(8, ANY, null, null, 4);

		loadEnts();
		tiles.follow(FlxG.camera, 0, true);
		FlxCollision.createCameraWall(FlxG.camera, true, 2, true);
	}

	var level:String = null;
	var tiles:FlxTilemap;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Sound.updateSounds(elapsed);

		if (FlxG.keys.justPressed.ESCAPE && !Std.isOfType(FlxG.state, MenuState) && subState != null)
			openSubState(new PauseSubstate());
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
		add(coolSplash);
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
				default:
					interactables.add(new Interactable(e.x, e.y, getEntityGraphic(e.name), spr ->
					{
						if (e.values.SwitchState == true)
						{
							switch (e.values.State)
							{
								case "SpaceStation": FlxG.switchState(new SpaceStation());
								// case "DefaultState": FlxG.switchState(new DefaultState());
								case "PlayState": FlxG.switchState(new PlayState('house'));
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
