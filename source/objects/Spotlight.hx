package objects;

import flixel.tile.FlxTilemap;
import flixel.util.FlxSpriteUtil;
import openfl.geom.Rectangle;

class Spotlight extends FlxSprite
{
	var canvas:FlxSprite;
	var blank:FlxSprite;
	var pointAngle:Float = 90;
	var angleDiff:Int = 35;
	var tiles:FlxTilemap;

	var curColor:FlxColor = FlxColor.WHITE;
	var curSel:Int;
	var colorArray:Array<FlxColor> = [
		FlxColor.RED,
		FlxColor.BLUE,
		FlxColor.PURPLE,
		FlxColor.ORANGE,
		FlxColor.MAGENTA,
		FlxColor.CYAN
	];

	override public function new(x:Float, y:Float, tiles:Null<FlxTilemap>)
	{
		super(x, y);
		makeGraphic(1, 1, FlxColor.TRANSPARENT);

		if (tiles != null)
			this.tiles = tiles;
		blank = new FlxSprite(x - tiles.width, y - 20).makeGraphic(Std.int(tiles.width * 3), FlxG.height, FlxColor.TRANSPARENT);
		canvas = new FlxSprite(x - 500, y - 20);
		FlxTween.num(45, 135, 2, {ease: FlxEase.smootherStepInOut, type: PINGPONG}, val -> pointAngle = val);

		canvas.alpha = .2;
	}

	override public function draw()
	{
		updateCanvas();

		canvas.draw();
		super.draw();
	}

	function updateCanvas()
	{
		canvas.loadGraphicFromSprite(blank);
		canvas.pixels.fillRect(new Rectangle(0, 0, blank.width, blank.height), FlxColor.TRANSPARENT);

		var thisPoint = getPosition();

		var down = ((pointAngle - angleDiff) % 90) / 90;
		FlxG.watch.addQuick('down', down);
		var right = (1 - down);
		if ((pointAngle - angleDiff) > 90)
		{
			var place = right;
			right = down;
			down = place;
		}

		FlxG.watch.addQuick('right', right);
		FlxG.watch.addQuick('sum1', right + down);

		var distance:Int = 1000;

		var leftPoint = new FlxPoint(thisPoint.x + (distance * right), thisPoint.y + (distance * down));
		// tiles.ray(thisPoint, leftPoint, leftPoint);

		var down2 = ((pointAngle + angleDiff) % 90) / 90;
		var right2 = (1 - down2);
		if ((pointAngle + angleDiff) > 90)
		{
			var place = right2;
			right2 = down2;
			down2 = place;
		}
		FlxG.watch.addQuick('down2', down2);
		FlxG.watch.addQuick('right2', right2);
		FlxG.watch.addQuick('sum2', right2 + down2);
		var rightPoint = new FlxPoint(thisPoint.x + (distance * right2), thisPoint.y + (distance * down2));
		// tiles.ray(thisPoint, rightPoint, rightPoint);

		var vertices:Array<FlxPoint> = [thisPoint, rightPoint, leftPoint, thisPoint];

		for (point in vertices)
		{
			point.x -= canvas.x;
			point.y -= canvas.y;
		}
		FlxSpriteUtil.drawPolygon(canvas, vertices, curColor);
	}

	var resetTime = 2;
	var ticks:Float = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if ((ticks += elapsed) >= resetTime)
		{
			ticks = 0;
			curColor = colorArray.shift();
			colorArray.push(curColor);
			trace(colorArray);
		}
	}
}
