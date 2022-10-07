package objects;

import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.util.typeLimit.OneOfTwo;

/**quick and dirty player class**/
class Player extends FlxSprite
{
	public var controls(get, never):Controls;
	public var inCutscene:Bool = false;

	var _wc:Array<OneOfTwo<FlxObject, FlxGroup>> = [];
	var _pc:Array<OneOfTwo<FlxObject, FlxGroup>> = [];

	/**Adds `object` to the list of objects the player should collide with. If `player` is true, the object will collide with the entire hitbox of the player, otherwise the collision only checks near the feet (for walking around, etc).**/
	public function addCollision(object:OneOfTwo<FlxObject, FlxGroup>, player:Bool = true)
		if (player)
			_pc.push(object);
		else
			_wc.push(object);

	function get_controls():Controls
		return Setup.controls;

	var speed:Float = 250;
	var shadow:FlxSprite;

	/**There's weird collision behaviour when I put the spawn where I need it to be, but not when I start way below. maybe making it spawn below and then move it to where i want on the first update would do me good**/
	var dirtyWorkaround:Bool = false;

	public var hoveringSomething:Bool = false;

	override public function new(x:Float = 0, y:Float = 0, scale:Int = 1)
	{
		super(x, y + 500);
		facing = LEFT;

		Helpers.retChar('titusPlayer', true, this);

		this.scale.set(scale, scale);
		updateHitbox();
		setPosition(x * scale, y * scale + 500);

		shadow = new FlxSprite(this.x, this.y);
		shadow.makeGraphic(Math.ceil(width), 20, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawEllipse(shadow, 0, 0, shadow.width, shadow.height, FlxColor.BLACK);
		shadow.alpha = 0.4;
		shadow.setPosition(this.x, this.y + this.height - 10 + 100);
	}

	override public function update(elapsed:Float)
	{
		FlxG.watch.addQuick('inCutscene', inCutscene);

		if (!dirtyWorkaround)
		{
			dirtyWorkaround = true;
			y -= 500;
		}

		handleCollisions();
		super.update(elapsed);

		if (inCutscene || FlxG.state.subState != null)
		{
			velocity.set();
			return;
		}
		movementLogic();
		animationLogic();
	}

	override public function draw()
	{
		shadow.setPosition(x + shadow.width / 2 - width / 2, y + height - 10);
		shadow.draw();
		super.draw();
	}

	function handleCollisions()
	{
		for (i in _wc)
			FlxG.collide(i, shadow, processGroundCollide);

		for (i in _pc)
			FlxG.overlap(i, this);
	}

	function processGroundCollide(a:FlxObject, b:FlxObject)
		this.setPosition(b.x + b.width / 2 - this.width / 2, b.y + 10 - this.height);

	

	function animationLogic()
	{
		if (animation.curAnim != null)
			if (animation.curAnim.name == 'shock')
				if (animation.curAnim.finished)
					animation.play('walk');
				else
					return;
		if (velocity.x != 0 || velocity.y != 0)
			animation.play('walk');
		else
			animation.play('stand');

		facing = velocity.x > 0 ? RIGHT : velocity.x == 0 ? facing : LEFT;
	}

	function movementLogic()
	{
		if (animation.curAnim != null)
			if (animation.curAnim.name == 'shock')
			{
				velocity.set(0, 0);
				return;
			}
		// up/down movement
		if (controls.up)
			velocity.y = -speed;
		else if (controls.down)
			velocity.y = speed;
		else
			velocity.y = 0;

		// right/left movement
		if (controls.right)
			velocity.x = speed;
		else if (controls.left)
			velocity.x = -speed;
		else
			velocity.x = 0;

		// cancel velocity if holding both directions
		if (controls.up && controls.down)
			velocity.y = 0;
		if (controls.right && controls.left)
			velocity.x = 0;
	}
}
