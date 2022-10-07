package objects;

import flixel.group.FlxGroup.FlxTypedGroup;
import objects.DialogueBox.DialogueCutscene;

class Violet extends Interactable
{
	var grpBubbles:FlxTypedGroup<FlxSprite>;

	override public function new(x:Float, y:Float, scale:Int, dialogue:String)
	{
		super(x, y, 'assets/images/violet.png', spr ->
		{
			@:privateAccess
			var player = cast(FlxG.state, DefaultState).player;
			FlxG.state.add(new DialogueCutscene(dialogue, player, this, false, () ->
			{
				canHover = false;
				FlxG.state.add(new DialogueBox(player, 'WATCH OUT!', 0, 0, 32, 'Feed', false, true).start());
				@:privateAccess
				new FlxTimer().start(1, tmr ->
				{
					cast(FlxG.state, DefaultState).hacker.attack();
					FlxG.camera.follow(cast(FlxG.state, DefaultState).hacker, PLATFORMER, .1);
					new FlxTimer().start(3, tmr -> FlxG.camera.follow(player, PLATFORMER, .2));
				});
			}));
		});
		this.scale.set(scale, scale);
		updateHitbox();

		grpBubbles = new FlxTypedGroup();
	}

	override public function draw()
	{
		super.draw();
		grpBubbles.draw();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		grpBubbles.update(elapsed);
		if (FlxG.random.bool(.25))
		{
			var bubble = new FlxSprite(this.x + (6 * scale.x), this.y + (6 * scale.x), 'assets/images/juice.png');
			grpBubbles.add(bubble);
			bubble.velocity.y = FlxG.random.int(-20, -40);
			FlxTween.tween(bubble, {x: bubble.x + FlxG.random.int(10, 30)}, 2, {ease: FlxEase.smootherStepInOut, type: PINGPONG});
		}
	}
}
