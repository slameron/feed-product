package states;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import hscript.Interp;
import hscript.Parser;

class DefaultState extends FlxTransitionableState
{
	var loader:FlxOgmo3Loader;
	var interactables:FlxTypedGroup<Interactable>;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Sound.updateSounds(elapsed);
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

	function loadEnts()
	{
		loader.loadEntities(e ->
		{
			switch (e.name)
			{
				default:
					#if hscript
					var parser = new Parser();
					var interp = new Interp();

					// not really getting why this doesnt work but im determined to get it. this is huge!
					// also scale down the door to save pixels, scale up with code using the entities tile size vs the sprite size. math! using project.entities
					interp.variables.set('FlxG', FlxG);
					var goo:FlxSprite->Void = interp.execute(parser.parseString('spr -> {${e.values.OnInteract}}'));
					trace(goo);
					interactables.add(new Interactable(e.x, e.y, getEntityGraphic(e.name), goo));
					#end
			}
		}, 'ents_fg');
	}
}
