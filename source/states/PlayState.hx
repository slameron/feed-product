package states;

import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.DialogueBox.DialogueCutscene;

class PlayState extends DefaultState
{
	var wires:Interactable;
	var sittingMarty:Interactable;

	override public function create()
	{
		super.create();

		wires = new Interactable(0, 0, 'assets/images/wires.png', guy ->
		{
			if (guy.animation.curAnim.name == 'shock')
				return;

			guy.animation.play('shock', true);
			Sound.play('sound_zap', .2);

			guy.animation.finishCallback = name -> if (name == 'shock')
			{
				guy.animation.play('walk');
				var emitter:FlxEmitter = new FlxEmitter(guy.x + (guy.width / 2), guy.y + (6 * 4), 30);
				emitter.makeParticles(2, 2, FlxColor.BLACK, 30);
				emitter.scale.set(1, 1, 1, 1, 20, 20, 50, 50);
				emitter.angularVelocity.set(0, 50, 20, 100);
				emitter.alpha.set(0.6, 0.6, 0.0, 0.0);
				emitter.launchMode = SQUARE;
				emitter.velocity.set(-50, -40, 50, -10, -50, -100, 50, -50);
				emitter.start();
				insert(members.indexOf(guy), emitter);
			};
		}, true, 13, 11);
		wires.animation.add('reg', [0]);
		wires.animation.add('spark', [for (i in 1...12) i], 8, false);
		wires.animation.play("reg");

		interactables.add(wires);
		wires.scale.set(4, 4);
		wires.updateHitbox();
		wires.setPosition(404, 152 + (9 * 4));

		sittingMarty = new Interactable(0, 0, 'assets/images/martyZap.png', guy ->
		{
			add(new DialogueCutscene('letsGetOut', cast(guy, Player), sittingMarty));
			FlxG.save.data.spokeMarty = true;
			FlxG.save.flush();
		}, true, 18, 24);
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
			insert(members.indexOf(interactables), emitter);
		};
		interactables.add(sittingMarty);

		sittingMarty.scale.set(4, 4);
		sittingMarty.updateHitbox();
		sittingMarty.setPosition(wires.x + 10 * 4, 40 * 4);

		player.setPosition(86 * 4, (24.5 * 4) + 500);
		@:privateAccess player.dirtyWorkaround = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.random.bool(.5))
			wires.animation.play('spark', true);
		if (FlxG.random.bool(.25))
			sittingMarty.animation.play('spark', true);
	}
}
