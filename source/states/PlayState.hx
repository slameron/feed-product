package states;

import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;

class PlayState extends DefaultState
{
	var player:Player;

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
		tiles.setTileProperties(0, NONE, null, null, 2);
		tiles.setTileProperties(2, ANY, null, null, 2);

		add(player = new Player(86, 24.5, 4));
		player.addCollision(tiles, false);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
