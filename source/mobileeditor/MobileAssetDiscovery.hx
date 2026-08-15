package mobileeditor;

#if sys
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef MobileCharacterInfo = {
    var id:String;
    var displayName:String;
    var source:String;
    var image:String;
    var healthIcon:String;
    var animations:Array<String>;
}

class MobileAssetDiscovery
{
    static function addUnique(target:Array<String>, seen:Map<String, Bool>, value:String):Void
    {
        if (value == null || value.length == 0 || seen.exists(value)) return;
        seen.set(value, true);
        target.push(value);
    }

    public static function listCharacters():Array<String>
    {
        var result:Array<String> = [];
        var seen:Map<String, Bool> = new Map();

        try
        {
            for (id in CoolUtil.coolTextFile(Paths.txt('characterList'))) addUnique(result, seen, id);
        }
        catch (_:Dynamic) {}

        #if sys
        var dirs:Array<String> = [];
        var project = MobileProjectContext.projectRoot();
        if (project.length > 0) dirs.push(project + 'characters/');
        #if MODS_ALLOWED
        dirs.push(Paths.mods('characters/'));
        #end
        dirs.push(Paths.getPreloadPath('characters/'));

        for (dir in dirs)
        {
            if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir)) continue;
            for (file in FileSystem.readDirectory(dir))
            {
                var full = dir + file;
                if (FileSystem.isDirectory(full) || !file.toLowerCase().endsWith('.json')) continue;
                var id = file.substr(0, file.length - 5);
                if (!id.endsWith('-dead')) addUnique(result, seen, id);
            }
        }
        #end

        result.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
        return result;
    }

    public static function getCharacterInfo(id:String):MobileCharacterInfo
    {
        var info:MobileCharacterInfo = {
            id: id,
            displayName: prettify(id),
            source: 'builtin',
            image: '',
            healthIcon: 'face',
            animations: []
        };

        #if sys
        var candidates:Array<{path:String, source:String}> = [];
        var project = MobileProjectContext.projectRoot();
        if (project.length > 0) candidates.push({path: project + 'characters/' + id + '.json', source: 'mod'});
        #if MODS_ALLOWED
        candidates.push({path: Paths.mods('characters/' + id + '.json'), source: 'mods'});
        #end
        candidates.push({path: Paths.getPreloadPath('characters/' + id + '.json'), source: 'builtin'});

        for (candidate in candidates)
        {
            if (!FileSystem.exists(candidate.path)) continue;
            try
            {
                var json:Dynamic = Json.parse(File.getContent(candidate.path));
                info.source = candidate.source;
                if (Reflect.hasField(json, 'image')) info.image = Std.string(Reflect.field(json, 'image'));
                if (Reflect.hasField(json, 'healthicon')) info.healthIcon = Std.string(Reflect.field(json, 'healthicon'));
                var animations:Dynamic = Reflect.field(json, 'animations');
                if (animations != null)
                {
                    for (anim in cast(animations, Array<Dynamic>))
                    {
                        var name = Reflect.field(anim, 'anim');
                        if (name != null) info.animations.push(Std.string(name));
                    }
                }
                break;
            }
            catch (_:Dynamic) {}
        }
        #end
        return info;
    }

    public static function listWeeks():Array<String>
    {
        var result:Array<String> = [];
        var seen:Map<String, Bool> = new Map();
        #if sys
        var dirs:Array<String> = [];
        var project = MobileProjectContext.projectRoot();
        if (project.length > 0) dirs.push(project + 'weeks/');
        dirs.push(Paths.getPreloadPath('weeks/'));
        for (dir in dirs)
        {
            if (!FileSystem.exists(dir)) continue;
            for (file in FileSystem.readDirectory(dir))
                if (file.toLowerCase().endsWith('.json')) addUnique(result, seen, file.substr(0, file.length - 5));
        }
        #end
        result.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
        return result;
    }

    public static function listFonts():Array<String>
    {
        var result:Array<String> = ['vcr.ttf'];
        var seen:Map<String, Bool> = ['vcr.ttf' => true];
        #if sys
        var dirs:Array<String> = [Paths.getPreloadPath('../fonts/')];
        var project = MobileProjectContext.projectRoot();
        if (project.length > 0) dirs.unshift(project + 'fonts/');
        for (dir in dirs)
        {
            if (!FileSystem.exists(dir)) continue;
            for (file in FileSystem.readDirectory(dir))
            {
                var lower = file.toLowerCase();
                if (lower.endsWith('.ttf') || lower.endsWith('.otf')) addUnique(result, seen, file);
            }
        }
        #end
        return result;
    }

    public static function prettify(id:String):String
    {
        if (id == null) return '';
        var words = id.replace('_', ' ').replace('-', ' ').split(' ');
        for (i in 0...words.length)
            if (words[i].length > 0) words[i] = words[i].substr(0, 1).toUpperCase() + words[i].substr(1);
        return words.join(' ');
    }
}
