package util;

#if cpp
import Sys.sleep;
import discord_rpc.DiscordRpc;

using StringTools;

class Discord
{
	public static var isInitialized:Bool = false;

	static var startTime:Null<Float> = null;

	public function new()
	{
		DiscordRpc.start({
			clientID: "998993424101421237",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: "Playing Diced Up!",
			state: 'Just started playing',
			largeImageKey: 'largeicon',
			largeImageText: null
		});
		trace("Discord Client initialized successfully");
		isInitialized = true;
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Discord client Error! $_code : $_message');
		trace("Discord Client Failed to Initialize");
		isInitialized = false;
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Discord client Disconnected! $_code : $_message');
		isInitialized = false;
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new Discord();
		});
	}

	/**Change the status on your discord profile.
		@param details The first line, under the name of your game.
		@param state The second line, useful for more details such as level, health, etc.
		@param largeImageKey the name of the asset in discord developer portal for the large image.
		@param largeImageText the tooltip text that will appear when you hover over the large image.
		@param smallImageKey the name of the asset in discord developer portal for the small image in the corner.
		@param smallImageText the tooltip text that will appear when you hover over the small image.
	**/
	public static function changePresence(details:String, state:Null<String>, ?largeImageKey:String, ?largeImageText:String, ?smallImageKey:String,
			?smallImageText:String, ?hasStartTimestamp:Bool, ?clearTimestamp:Bool, ?endTimestamp:Float)
	{
		if (!isInitialized)
		{
			trace('Discord client is not initialized. Failed to change presence');
			return;
		}
		var startTimestamp:Null<Float> = hasStartTimestamp ? Date.now().getTime() : null;

		if (startTimestamp != null)
			startTime = startTimestamp;

		if (clearTimestamp)
			startTime = null;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: largeImageKey != null ? largeImageKey : 'largeicon',
			largeImageText: largeImageText,
			smallImageKey: smallImageKey,
			smallImageText: smallImageText,
			startTimestamp: Std.int(startTime / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
	}
}
#end
