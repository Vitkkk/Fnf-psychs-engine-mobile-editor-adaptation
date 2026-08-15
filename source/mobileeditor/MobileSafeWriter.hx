package mobileeditor;

#if sys
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class MobileSafeWriter
{
    static function ensureParent(path:String):Void
    {
        #if sys
        var slash = path.lastIndexOf('/');
        if (slash < 0) slash = path.lastIndexOf('\\');
        if (slash <= 0) return;
        var dir = path.substr(0, slash);
        ensureDirectoryRecursive(dir);
        #end
    }

    static function ensureDirectoryRecursive(path:String):Void
    {
        #if sys
        if (path == null || path.length == 0 || FileSystem.exists(path)) return;
        var normalized = path.replace('\\', '/');
        var parentPos = normalized.lastIndexOf('/');
        if (parentPos > 0) ensureDirectoryRecursive(normalized.substr(0, parentPos));
        if (!FileSystem.exists(normalized)) FileSystem.createDirectory(normalized);
        #end
    }

    public static function writeTextAtomic(path:String, data:String, backup:Bool = true):Bool
    {
        #if sys
        if (path == null || path.length == 0 || data == null) return false;
        ensureParent(path);
        var tmp = path + '.tmp';
        var bak = path + '.bak';
        try
        {
            File.saveContent(tmp, data);
            // Read-back verifies the temporary file was actually written before replacement.
            if (File.getContent(tmp) != data) return false;
            if (backup && FileSystem.exists(path))
            {
                if (FileSystem.exists(bak)) FileSystem.deleteFile(bak);
                FileSystem.rename(path, bak);
            }
            if (FileSystem.exists(path)) FileSystem.deleteFile(path);
            FileSystem.rename(tmp, path);
            return true;
        }
        catch (e:Dynamic)
        {
            if (FileSystem.exists(tmp)) try FileSystem.deleteFile(tmp) catch (_:Dynamic) {}
            if (!FileSystem.exists(path) && FileSystem.exists(bak)) try FileSystem.rename(bak, path) catch (_:Dynamic) {}
            trace('[MobileSafeWriter] Failed to write ' + path + ': ' + e);
            return false;
        }
        #else
        return false;
        #end
    }

    public static function writeJsonAtomic(path:String, value:Dynamic, backup:Bool = true):Bool
    {
        #if sys
        var encoded = Json.stringify(value, '\t');
        try Json.parse(encoded) catch (e:Dynamic) return false;
        return writeTextAtomic(path, encoded, backup);
        #else
        return false;
        #end
    }

    public static function autosave(relativePath:String, value:Dynamic):Bool
    {
        var root = MobileProjectContext.projectRoot();
        if (root.length == 0) return false;
        return writeJsonAtomic(root + '.editor/autosaves/' + relativePath, value, false);
    }
}
