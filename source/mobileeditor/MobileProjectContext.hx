package mobileeditor;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/**
 * Centralizes the currently selected mod/project for mobile editor tooling.
 * It deliberately does not alter gameplay-side mod loading semantics.
 */
class MobileProjectContext
{
    public static var currentMod(default, set):String = '';

    static function set_currentMod(value:String):String
    {
        currentMod = sanitizeModName(value);
        if (currentMod.length > 0)
            Paths.currentModDirectory = currentMod;
        return currentMod;
    }

    public static function sanitizeModName(value:String):String
    {
        if (value == null) return '';
        var out = value.trim();
        out = out.replace('\\', '-').replace('/', '-').replace(':', '-');
        while (out.indexOf('..') != -1) out = out.replace('..', '.');
        return out;
    }

    public static function modsRoot():String
    {
        #if MODS_ALLOWED
        return Paths.mods();
        #else
        return '';
        #end
    }

    public static function projectRoot(?mod:String):String
    {
        var target = sanitizeModName(mod == null ? currentMod : mod);
        if (target.length == 0) return modsRoot();
        return modsRoot() + target + '/';
    }

    public static function ensureProject(?mod:String):Bool
    {
        #if sys
        var root = projectRoot(mod);
        if (root.length == 0) return false;
        if (!FileSystem.exists(root)) FileSystem.createDirectory(root);
        return FileSystem.exists(root) && FileSystem.isDirectory(root);
        #else
        return false;
        #end
    }

    public static function listProjects():Array<String>
    {
        var result:Array<String> = [];
        #if sys
        var root = modsRoot();
        if (!FileSystem.exists(root)) return result;
        for (entry in FileSystem.readDirectory(root))
        {
            var full = root + entry;
            if (FileSystem.isDirectory(full) && !Paths.ignoreModFolders.exists(entry)) result.push(entry);
        }
        result.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
        #end
        return result;
    }
}
