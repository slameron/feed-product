package states;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.debug.console.ConsoleUtil;
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
					interactables.add(new Interactable(e.x, e.y, getEntityGraphic(e.name), spr ->
					{
						if (e.values.SwitchState)
							FlxG.switchState(new State);
					}));
			}
		}, 'ents_fg');
	}
}

enum abstract State(String)
{
	var DefaultState = 'DefaultState';
}
