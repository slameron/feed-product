package objects;

import flixel.FlxObject;
import flixel.util.FlxSpriteUtil;

class Shadow extends FlxSprite
{
	public var parent:FlxSprite;

	override public function new(x:Float, y:Float)
	{
		super(x, y);
	}
	/*override function set_x(newX:Float):Float
		{
			// trace('setting shadow x');
			if (parent != null)
				parent.x = newX + width / 2 - parent.width / 2;
			return x = newX;
		}

		override function set_y(newX:Float):Float
		{
			// trace("setting shadow y");
			if (parent != null)
				parent.y = newX + 10 - parent.height;
			return y = newX;
	}*/
}

/**quick and dirty player class**/
class Player extends FlxSprite
{
	public var controls(get, never):Controls;

	var _wc:Array<FlxObject> = [];
	var _pc:Array<FlxObject> = [];

	/**Adds `object` to the list of objects the player should collide with. If `player` is true, the object will collide with the entire hitbox of the player, otherwise the collision only checks near the feet (for walking around, etc).**/
	public function addCollision(object:FlxObject, player:Bool = true)
		if (player)
			_pc.push(object);
		else
			_wc.push(object);

	function get_controls():Controls
		return Setup.controls;

	var speed:Float = 250;
	var shadow:Shadow;

	/**There's weird collision behaviour when I put the spawn where I need it to be, but not when I start way below. maybe making it spawn below and then move it to where i want on the first update would do me good**/
	var dirtyWorkaround:Bool = false;

	override public function new(x:Float = 0, y:Float = 0, scale:Int = 1)
	{
		super(x, y + 500);

		Helpers.retChar('titusPlayer', true, this);

		this.scale.set(scale, scale);
		updateHitbox();
		setPosition(x * scale, y * scale + 500);

		shadow = new Shadow(this.x, this.y);
		shadow.makeGraphic(Math.ceil(width), 20, FlxColor.TRANSPARENT);
		shadow.parent = this;
		FlxSpriteUtil.drawEllipse(shadow, 0, 0, shadow.width, shadow.height, FlxColor.BLACK);
		shadow.alpha = 0.4;
		shadow.setPosition(this.x, this.y + this.height - 10 + 100);
	}

	override public function update(elapsed:Float)
	{
		controls.update(elapsed);

		if (!dirtyWorkaround)
		{
			dirtyWorkaround = true;
			y -= 500;
		}

		movementLogic();
		animationLogic();

		handleCollisions();
		super.update(elapsed);

		FlxG.watch.addQuick('stuff', 'y: ${this.y}, h: ${this.height}, sy: ${shadow.y + shadow.height / 2}');
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
			FlxG.collide(i, this);
	}

	function processGroundCollide(a:FlxObject, b:FlxObject)
		this.setPosition(b.x + b.width / 2 - this.width / 2, b.y + 10 - this.height);

	function animationLogic()
	{
		if (velocity.x != 0 || velocity.y != 0)
			animation.play('walk');
		else
			animation.play('stand');

		facing = velocity.x > 0 ? RIGHT : velocity.x == 0 ? facing : LEFT;
	}

	function movementLogic()
	{
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
