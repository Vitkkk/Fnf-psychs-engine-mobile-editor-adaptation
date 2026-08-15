package mobileeditor.week;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.utils.Assets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import editors.WeekEditorState;
import mobileeditor.MobileAssetDiscovery;
import mobileeditor.MobileProjectContext;
import mobileeditor.ui.MobileButton;
import WeekData.WeekFile;

/**
 * Story-Mode-like Week browser for touch screens.
 * Existing weeks are presented as large visual cards; creation is always the
 * last large action, matching the requested "weeks -> + CRIAR WEEK" flow.
 */
class MobileWeekListState extends MusicBeatState
{
    static inline var ITEMS_PER_PAGE:Int = 4;
    var weekIds:Array<String> = [];
    var page:Int = 0;
    var dynamicItems:Array<FlxBasic> = [];
    var pageLabel:FlxText;

    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;
        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

        var top = new FlxSprite(0, 0).makeGraphic(FlxG.width, 92, 0xFF101217);
        add(top);

        var title = new FlxText(28, 17, 420, 'MOBILE WEEK EDITOR', 31);
        title.setFormat(Paths.font('vcr.ttf'), 31, FlxColor.WHITE, LEFT);
        add(title);

        var project = MobileProjectContext.activeMod();
        var projectText = new FlxText(470, 24, FlxG.width - 498,
            'MOD: ' + (project.length > 0 ? project : 'mods/'), 18);
        projectText.setFormat(Paths.font('vcr.ttf'), 18, 0xFFB8C3D9, RIGHT);
        add(projectText);

        add(new MobileButton(28, FlxG.height - 72, 150, 48, '< VOLTAR', function() {
            MusicBeatState.switchState(new editors.MasterEditorMenu());
        }));
        add(new MobileButton(194, FlxG.height - 72, 145, 48, '< PAG', function() {
            if (page > 0) { page--; rebuildCards(); }
        }));
        add(new MobileButton(FlxG.width - 173, FlxG.height - 72, 145, 48, 'PAG >', function() {
            if ((page + 1) * ITEMS_PER_PAGE < weekIds.length) { page++; rebuildCards(); }
        }));

        pageLabel = new FlxText(360, FlxG.height - 64, FlxG.width - 720, '', 18);
        pageLabel.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, CENTER);
        add(pageLabel);

        refreshWeeks();
    }

    function refreshWeeks():Void
    {
        weekIds = MobileAssetDiscovery.listWeeks();
        var maxPage = weekIds.length == 0 ? 0 : Std.int((weekIds.length - 1) / ITEMS_PER_PAGE);
        if (page > maxPage) page = maxPage;
        rebuildCards();
    }

    function rebuildCards():Void
    {
        for (item in dynamicItems) { remove(item, true); item.destroy(); }
        dynamicItems = [];

        var start = page * ITEMS_PER_PAGE;
        var end = Std.int(Math.min(start + ITEMS_PER_PAGE, weekIds.length));
        var y:Float = 112;

        for (i in start...end)
        {
            var id = weekIds[i];
            var week = loadWeek(id);
            var title = week != null && week.storyName != null && week.storyName.length > 0
                ? week.storyName : MobileAssetDiscovery.prettify(id).toUpperCase();
            var songs:Array<String> = [];
            if (week != null && week.songs != null)
            {
                for (entry in week.songs)
                {
                    var row:Array<Dynamic> = cast entry;
                    if (row != null && row.length > 0) songs.push(Std.string(row[0]));
                }
            }

            var card = new FlxSprite(34, y).makeGraphic(FlxG.width - 68, 116, 0xFFF9CF51);
            dynamicItems.push(card); add(card);

            var nameText = new FlxText(54, y + 16, FlxG.width - 390, title, 28);
            nameText.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.BLACK, LEFT);
            dynamicItems.push(nameText); add(nameText);

            var tracks = new FlxText(54, y + 57, FlxG.width - 390,
                songs.length == 0 ? 'SEM MUSICAS' : songs.join('  •  '), 17);
            tracks.setFormat(Paths.font('vcr.ttf'), 17, 0xFF6D3B52, LEFT);
            dynamicItems.push(tracks); add(tracks);

            var idText = new FlxText(54, y + 86, FlxG.width - 390, '[' + id + ']', 14);
            idText.setFormat(Paths.font('vcr.ttf'), 14, 0xFF5E5E5E, LEFT);
            dynamicItems.push(idText); add(idText);

            var captured = id;
            var edit = new MobileButton(FlxG.width - 300, y + 30, 240, 58, 'EDITAR WEEK', function() openWeek(captured));
            dynamicItems.push(edit); add(edit);
            y += 128;
        }

        // The create action is intentionally placed after the last existing Week.
        if (end >= weekIds.length)
        {
            var createY = y + 4;
            if (createY < FlxG.height - 140)
            {
                var create = new MobileButton(FlxG.width / 2 - 190, createY, 380, 62, '+ CRIAR WEEK', function() {
                    MusicBeatState.switchState(new MobileWeekCreateState());
                });
                dynamicItems.push(create); add(create);
            }
        }

        if (weekIds.length == 0)
        {
            var empty = new FlxText(34, 150, FlxG.width - 68,
                'Nenhuma Week encontrada. Crie a primeira sem editar JSON.', 24);
            empty.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
            dynamicItems.push(empty); add(empty);

            var create = new MobileButton(FlxG.width / 2 - 190, 235, 380, 64, '+ CRIAR WEEK', function() {
                MusicBeatState.switchState(new MobileWeekCreateState());
            });
            dynamicItems.push(create); add(create);
        }

        pageLabel.text = 'Pagina ' + (page + 1) + ' / ' + Math.max(1, Math.ceil(weekIds.length / ITEMS_PER_PAGE));
    }

    function openWeek(id:String):Void
    {
        var week = loadWeek(id);
        MusicBeatState.switchState(new MobileWeekEditorState(id, week));
    }

    function loadWeek(id:String):WeekFile
    {
        var raw:String = null;
        #if sys
        var modPath = MobileProjectContext.projectRoot() + 'weeks/' + id + '.json';
        if (FileSystem.exists(modPath)) raw = File.getContent(modPath);
        #end
        if (raw == null)
        {
            var builtin = Paths.getPreloadPath('weeks/' + id + '.json');
            if (Assets.exists(builtin)) raw = Assets.getText(builtin);
        }
        if (raw != null)
        {
            try return cast Json.parse(raw) catch (_:Dynamic) {}
        }
        return WeekData.createWeekFile();
    }

    override function update(elapsed:Float):Void
    {
        #if android
        if (FlxG.android.justReleased.BACK)
        {
            MusicBeatState.switchState(new editors.MasterEditorMenu());
            return;
        }
        #end
        super.update(elapsed);
    }
}
