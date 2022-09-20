package;

class Assets
{
	static var extension:String = #if desktop '.ogg' #else '.mp3' #end;

	public static function sound(sound:String, ?extensionOverride:String):String
		return 'assets/sounds/$sound${extensionOverride != null ? extensionOverride : extension}';
}
