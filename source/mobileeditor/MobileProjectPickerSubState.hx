package mobileeditor;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import mobileeditor.ui.MobileButton;

/** Large project/mod chooser so saves always target an explicit mods/<name>/ root. */
class MobileProjectPickerSubState extends MusicBeatSubstate
{
    static inline var ITEMS_PER_PAGE:Int = 6;
    var projects:Array<String> = [];
    var page:Int = 0;
    var rows:Array<FlxBasic> = [];
    var pageText:FlxText;
    var onSelect:String->Void;

    public function new(onSelect:String->Void)
    {
        super();
        this.onSelect = onSelect;
    }

    override function create():Void
    {
        super.create();
        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xF21A1D24));
        var title = new FlxText(28, 20, FlxG.width - 56, 'ESCOLHER MOD / PROJETO', 30);
        title.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT);
        add(title);

        var hint = new FlxText(28, 60, FlxG.width - 56,
            'A Week sera salva diretamente dentro deste mod.', 17);
        hint.setFormat(Paths.font('vcr.ttf'), 17, 0xFFB8C3D9, LEFT);
        add(hint);

        projects = MobileProjectContext.listProjects();
        pageText = new FlxText(360, FlxG.height - 64, FlxG.width - 720, '', 18);
        pageText.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, CENTER);
        add(pageText);

        add(new MobileButton(28, FlxG.height - 72, 150, 48, '< VOLTAR', close));
        add(new MobileButton(194, FlxG.height - 72, 130, 48, '< PAG', function() {
            if (page > 0) { page--; rebuild(); }
        }));
        add(new MobileButton(FlxG.width - 158, FlxG.height - 72, 130, 48, 'PAG >', function() {
            if ((page + 1) * ITEMS_PER_PAGE < projects.length) { page++; rebuild(); }
        }));
        rebuild();
    }

    function rebuild():Void
    {
        for (item in rows) { remove(item, true); item.destroy(); }
        rows = [];
        var start = page * ITEMS_PER_PAGE;
        var end = Std.int(Math.min(start + ITEMS_PER_PAGE, projects.length));
        var y:Float = 100;
        for (i in start...end)
        {
            var project = projects[i];
            var captured = project;
            var selected = MobileProjectContext.activeMod() == project ? '  [ATUAL]' : '';
            var button = new MobileButton(44, y, FlxG.width - 88, 70, project + selected, function() {
                MobileProjectContext.currentMod = captured;
                onSelect(captured);
                close();
            });
            rows.push(button); add(button);
            y += 78;
        }
        if (projects.length == 0)
        {
            var empty = new FlxText(30, 180, FlxG.width - 60,
                'Nenhuma pasta de mod foi encontrada em mods/.', 22);
            empty.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.WHITE, CENTER);
            rows.push(empty); add(empty);
        }
        pageText.text = 'Pagina ' + (page + 1) + ' / ' + Math.max(1, Math.ceil(projects.length / ITEMS_PER_PAGE));
    }

    override function update(elapsed:Float):Void
    {
        #if android
        if (FlxG.android.justReleased.BACK) { close(); return; }
        #end
        super.update(elapsed);
    }
}
