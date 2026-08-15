package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;

using StringTools;

typedef WeekFile =
{
	var songs:Array<Dynamic>;
	var weekCharacters:Array<String>;
	var weekBackground:String;
	var weekBefore:String;
	var storyName:String;
	var weekName:String;
	var freeplayColor:Array<Int>;
	var startUnlocked:Bool;
	var hideStoryMode:Bool;
	var hideFreeplay:Bool;
	var showcutscene:Bool;
	var currentcutscene:String;
}

class WeekData
{
	public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksList:Array<String> = [];
	public var folder:String = '';

	public var songs:Array<Dynamic>;
	public var weekCharacters:Array<String>;
	public var weekBackground:String;
	public var weekBefore:String;
	public var storyName:String;
	public var weekName:String;
	public var freeplayColor:Array<Int>;
	public var startUnlocked:Bool;
	public var hideStoryMode:Bool;
	public var hideFreeplay:Bool;
	public var showcutscene:Bool;
	public var currentcutscene:String;

	public static function createWeekFile():WeekFile
	{
		return {
			songs: [["Bopeebo", "dad", [146, 113, 253], "Bopeebo"], ["Fresh", "dad", [146, 113, 253], "Fresh"], ["Dad Battle", "dad", [146, 113, 253], "Dad Battle"]],
			weekCharacters: ['dad', 'bf', 'gf'],
			weekBackground: 'stage',
			weekBefore: 'tutorial',
			storyName: 'Your New Week',
			weekName: 'Custom Week',
			freeplayColor: [146, 113, 253],
			startUnlocked: true,
			hideStoryMode: false,
			hideFreeplay: false,
			showcutscene: false,
			currentcutscene: 'template'
		};
	}

	public function new(weekFile:WeekFile)
	{
		songs = weekFile.songs;
		weekCharacters = weekFile.weekCharacters;
		weekBackground = weekFile.weekBackground;
		weekBefore = weekFile.weekBefore;
		storyName = weekFile.storyName;
		weekName = weekFile.weekName;
		freeplayColor = weekFile.freeplayColor;
		startUnlocked = weekFile.startUnlocked;
		hideStoryMode = weekFile.hideStoryMode;
		hideFreeplay = weekFile.hideFreeplay;
		showcutscene = weekFile.showcutscene;
		currentcutscene = weekFile.currentcutscene;
	}

	/**
	 * Reloads vanilla and the currently selected mod. Custom week JSON files are
	 * discovered even when the author did not manually maintain weekList.txt.
	 * Mod JSON takes precedence over a vanilla file with the same ID.
	 */
	public static function reloadWeekFiles(isStoryMode:Null<Bool> = false):Void
	{
		weeksList = [];
		weeksLoaded.clear();

		var ids:Array<String> = [];
		var seen:Map<String, Bool> = new Map();
		var preloadRoot = Paths.getPreloadPath();
		collectWeekIds(preloadRoot, ids, seen);

		#if MODS_ALLOWED
		var modName = Paths.currentModDirectory;
		var modRoot:String = null;
		if (modName != null && modName.length > 0)
		{
			modRoot = Paths.mods(modName + '/');
			collectWeekIds(modRoot, ids, seen);
		}
		#end

		for (id in ids)
		{
			var week:WeekFile = null;
			var folder = '';

			#if MODS_ALLOWED
			if (modRoot != null)
			{
				var modPath = modRoot + 'weeks/' + id + '.json';
				week = getWeekFile(modPath);
				if (week != null) folder = modName;
			}
			#end

			if (week == null) week = getWeekFile(preloadRoot + 'weeks/' + id + '.json');
			if (week == null) continue;

			var data = new WeekData(week);
			data.folder = folder;
			if (isStoryMode == null || (isStoryMode && !data.hideStoryMode) || (!isStoryMode && !data.hideFreeplay))
			{
				weeksLoaded.set(id, data);
				weeksList.push(id);
			}
		}
	}

	static function collectWeekIds(root:String, ids:Array<String>, seen:Map<String, Bool>):Void
	{
		if (root == null || root.length == 0) return;
		var listPath = root + 'weeks/weekList.txt';
		var text:String = null;

		#if sys
		if (FileSystem.exists(listPath)) text = File.getContent(listPath);
		#end
		if (text == null && OpenFlAssets.exists(listPath)) text = Assets.getText(listPath);
		if (text != null)
		{
			for (line in text.split('\n'))
			{
				var id = line.trim();
				if (id.length > 0 && !seen.exists(id)) { seen.set(id, true); ids.push(id); }
			}
		}

		#if sys
		var dir = root + 'weeks/';
		if (FileSystem.exists(dir) && FileSystem.isDirectory(dir))
		{
			for (file in FileSystem.readDirectory(dir))
			{
				if (!file.toLowerCase().endsWith('.json')) continue;
				var id = file.substr(0, file.length - 5);
				if (!seen.exists(id)) { seen.set(id, true); ids.push(id); }
			}
		}
		#end
	}

	private static function getWeekFile(path:String):WeekFile
	{
		var rawJson:String = null;
		#if sys
		if (FileSystem.exists(path)) rawJson = File.getContent(path);
		#end
		if (rawJson == null && OpenFlAssets.exists(path)) rawJson = Assets.getText(path);
		if (rawJson != null && rawJson.length > 0)
		{
			try return cast Json.parse(rawJson) catch (_:Dynamic) {}
		}
		return null;
	}

	public static function getWeekFileName():String return weeksList[PlayState.storyWeek];
	public static function getCurrentWeek():WeekData return weeksLoaded.get(weeksList[PlayState.storyWeek]);

	public static function setDirectoryFromWeek(?data:WeekData = null):Void
	{
		Paths.currentModDirectory = '';
		if (data != null && data.folder != null && data.folder.length > 0) Paths.currentModDirectory = data.folder;
	}
}
