package mobileeditor;

class MobileEditorSavePaths
{
    public static function week(weekId:String):String
    {
        return MobileProjectContext.projectRoot() + 'weeks/' + safeId(weekId) + '.json';
    }

    public static function song(songId:String, ?difficulty:String = ''):String
    {
        var id = safeId(songId);
        var suffix = difficulty == null || difficulty.length == 0 ? '' : '-' + safeId(difficulty);
        return MobileProjectContext.projectRoot() + 'data/' + id + '/' + id + suffix + '.json';
    }

    public static function events(songId:String):String
    {
        var id = safeId(songId);
        return MobileProjectContext.projectRoot() + 'data/' + id + '/events.json';
    }

    static function safeId(value:String):String
    {
        if (value == null || value.length == 0) return 'untitled';
        return Paths.formatToSongPath(value).split('/').join('-').split('\\').join('-');
    }
}
