package mobileeditor.week;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
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
import WeekData.WeekFile;

/**
 * Touch-first Week Editor entry screen. Keeps the classic editor available,
 * while making the normal Android flow a large-button list + create action.
 */
class MobileWeekListState extends MusicBeatState
{
    static inline var PAGE_SIZE:Int = 6;
    var weekIds:Array<String> = [];
    var page:Int = 0;
    var buttons:Array<FlxButton> = [];
    var pageLabel:FlxText;

    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF171A20);
        add(bg);

        var title = new FlxText(36, 22, FlxG.width - 72, 'WEEK EDITOR', 34);
        title.setFormat(Paths.font('vcr.ttf'), 34, FlxColor.WHITE, LEFT);
        add(title);

        var project = MobileProjectContext.activeMod();
        var projectText = new FlxText(36, 66, FlxG.width - 72,
            'Projeto atual: ' + (project.length > 0 ? project : 'mods/'), 20);
        projectText.setFormat(Paths.font('vcr.ttf'), 20, 0xFFB8C3D9, LEFT);
        add(projectText);

        var back = bigButton(36, 106, 150, 54, '< Voltar', function() {
            MusicBeatState.switchState(new editors.MasterEditorMenu());
        });
        add(back);

        var create = bigButton(204, 106, 260, 54, '+ CRIAR WEEK', function() {
            MusicBeatState.switchState(new MobileWeekCreateState());
        });
        add(create);

        var classic = bigButton(482, 106, 210, 54, 'Editor classico', function() {
            MusicBeatState.switchState(new WeekEditorState());
        });
        add(classic);

        var refresh = bigButton(710, 106, 180, 54, 'Atualizar', refreshWeeks);
        add(refresh);

        var prev = bigButton(36, FlxG.height - 72, 180, 48, '< Pagina', function() {
            if (page > 0) { page--; rebuildCards(); }
        });
        add(prev);

        pageLabel = new FlxText(230, FlxG.height - 66, 300, '', 22);
        pageLabel.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.WHITE, CENTER);
        add(pageLabel);

        var next = bigButton(544, FlxG.height - 72, 180, 48, 'Pagina >', function() {
            if ((page + 1) * PAGE_SIZE < weekIds.length) { page++; rebuildCards(); }
        });
        add(next);

        refreshWeeks();
    }

    function refreshWeeks():Void
    {
        weekIds = MobileAssetDiscovery.listWeeks();
        var maxPage = weekIds.length == 0 ? 0 : Std.int((weekIds.length - 1) / PAGE_SIZE);
        if (page > maxPage) page = maxPage;
        rebuildCards();
    }

    function rebuildCards():Void
    {
        for (button in buttons) {
            remove(button, true);
            button.destroy();
        }
        buttons = [];

        var start = page * PAGE_SIZE;
        var end = Std.int(Math.min(start + PAGE_SIZE, weekIds.length));
        var y:Float = 182;
        for (i in start...end)
        {
            var id = weekIds[i];
            var week = loadWeek(id);
            var label = MobileAssetDiscovery.prettify(id);
            var songCount = week != null && week.songs != null ? week.songs.length : 0;
            var songWord = songCount == 1 ? 'musica' : 'musicas';
            var button = bigButton(70, y, FlxG.width - 140, 66,
                label + '   |   ' + songCount + ' ' + songWord + '   [' + id + ']', function() {
                openWeek(id);
            });
            buttons.push(button);
            add(button);
            y += 76;
        }

        if (weekIds.length == 0)
        {
            var empty = bigButton(70, 210, FlxG.width - 140, 70, 'Nenhuma week encontrada - toque em + CRIAR WEEK', function() {
                MusicBeatState.switchState(new MobileWeekCreateState());
            });
            buttons.push(empty);
            add(empty);
        }
        pageLabel.text = 'Pagina ' + (page + 1) + ' / ' + Math.max(1, Math.ceil(weekIds.length / PAGE_SIZE));
    }

    function openWeek(id:String):Void
    {
        var week:WeekFile = loadWeek(id);
        WeekEditorState.weekFileName = id;
        MusicBeatState.switchState(new WeekEditorState(week));
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

    function bigButton(x:Float, y:Float, width:Float, height:Float, label:String, callback:Void->Void):FlxButton
    {
        var button = new FlxButton(x, y, label, callback);
        button.setGraphicSize(Std.int(width), Std.int(height));
        button.updateHitbox();
        button.label.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, CENTER);
        return button;
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
