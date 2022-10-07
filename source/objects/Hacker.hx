package objects;

import flixel.effects.particles.FlxEmitter;

class Hacker extends FlxSprite
{
	public var fighting:Bool = false;

	override public function new(x:Float, y:Float, scale:Int)
	{
		super(x, y);
		loadGraphic('assets/images/hacker.png');
		flipX = true;
		this.scale.set(scale, scale);
		updateHitbox();

		visible = false;

		FlxTween.tween(this, {y: y - 20}, 2, {ease: FlxEase.smootherStepInOut, type: PINGPONG});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override public function draw()
	{
		super.draw();
	}

	public function attack()
	{
		visible = true;
		new FlxTimer().start(4, tmr -> fighting = true);
	}
}
