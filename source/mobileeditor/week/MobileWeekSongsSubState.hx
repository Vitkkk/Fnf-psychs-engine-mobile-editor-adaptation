package mobileeditor.week;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import mobileeditor.ui.MobileButton;
import WeekData.WeekFile;

/**
 * Touch-first editor for the WeekFile.songs array.
 * It preserves the original Psych entry shape and only changes the song id/name
 * while keeping icon/color/extra values when an existing entry is edited.
 */
class MobileWeekSongsSubState extends MusicBeatSubstate
{
    static inline var ITEMS_PER_PAGE:Int = 4;

    var week:WeekFile;
    var onChanged:Void->Void;
    var page:Int = 0;
    var rows:Array<FlxBasic> = [];
    var pageText:FlxText;
    var addInput:FlxUIInputText;

    public function new(week:WeekFile, onChanged:Void->Void)
    {
        super();
        this.week = week;
        this.onChanged = onChanged;
    }

    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;
        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xF21A1D24));

        var title = new FlxText(28, 20, FlxG.width - 56, 'MUSICAS DA WEEK', 30);
        title.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT);
        add(title);

        addInput = new FlxUIInputText(28, 66, FlxG.width - 310, '', 21);
        addInput.setFormat(Paths.font('vcr.ttf'), 21, FlxColor.BLACK, LEFT);
        addInput.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
        add(addInput);

        add(new MobileButton(FlxG.width - 262, 62, 234, 52, '+ ADICIONAR', addSong));

        pageText = new FlxText(FlxG.width / 2 - 160, FlxG.height - 62, 320, '', 18);
        pageText.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, CENTER);
        add(pageText);

        add(new MobileButton(28, FlxG.height - 72, 150, 48, '< VOLTAR', function() {
            FlxG.stage.window.textInputEnabled = false;
            close();
        }));
        add(new MobileButton(194, FlxG.height - 72, 130, 48, '< PAG', function() {
            if (page > 0) { page--; rebuild(); }
        }));
        add(new MobileButton(FlxG.width - 158, FlxG.height - 72, 130, 48, 'PAG >', function() {
            if ((page + 1) * ITEMS_PER_PAGE < week.songs.length) { page++; rebuild(); }
        }));

        rebuild();
    }

    function addSong():Void
    {
        var name = StringTools.trim(addInput.text);
        if (name.length == 0) return;
        week.songs.push([name, 'dad', [146, 113, 253], name]);
        addInput.text = '';
        FlxG.stage.window.textInputEnabled = false;
        page = Std.int((week.songs.length - 1) / ITEMS_PER_PAGE);
        onChanged();
        rebuild();
    }

    function rebuild():Void
    {
        for (item in rows) { remove(item, true); item.destroy(); }
        rows = [];

        var maxPage = week.songs.length == 0 ? 0 : Std.int((week.songs.length - 1) / ITEMS_PER_PAGE);
        if (page > maxPage) page = maxPage;
        var start = page * ITEMS_PER_PAGE;
        var end = Std.int(Math.min(start + ITEMS_PER_PAGE, week.songs.length));
        var y:Float = 128;

        for (i in start...end)
        {
            var index = i;
            var entry:Array<Dynamic> = cast week.songs[index];
            var name = entry.length > 0 ? Std.string(entry[0]) : 'song';
            var icon = entry.length > 1 ? Std.string(entry[1]) : 'dad';

            var card = new FlxSprite(28, y).makeGraphic(FlxG.width - 56, 104, 0xFF262B35);
            rows.push(card); add(card);

            var title = new FlxText(46, y + 13, FlxG.width - 500, name, 22);
            title.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.WHITE, LEFT);
            rows.push(title); add(title);

            var subtitle = new FlxText(46, y + 49, FlxG.width - 500,
                'Nome interno: ' + normalizeSongId(name) + '  |  Icone: ' + icon, 15);
            subtitle.setFormat(Paths.font('vcr.ttf'), 15, 0xFFB8C3D9, LEFT);
            rows.push(subtitle); add(subtitle);

            var up = new MobileButton(FlxG.width - 430, y + 26, 78, 52, 'UP', function() move(index, -1));
            rows.push(up); add(up);
            var down = new MobileButton(FlxG.width - 340, y + 26, 78, 52, 'DOWN', function() move(index, 1));
            rows.push(down); add(down);
            var removeButton = new MobileButton(FlxG.width - 250, y + 26, 200, 52, 'REMOVER', function() removeSong(index));
            rows.push(removeButton); add(removeButton);
            y += 116;
        }

        if (week.songs.length == 0)
        {
            var empty = new FlxText(28, 180, FlxG.width - 56, 'Nenhuma musica. Digite acima e toque + ADICIONAR.', 21);
            empty.setFormat(Paths.font('vcr.ttf'), 21, FlxColor.WHITE, CENTER);
            rows.push(empty); add(empty);
        }

        pageText.text = 'Pagina ' + (page + 1) + ' / ' + Math.max(1, Math.ceil(week.songs.length / ITEMS_PER_PAGE))
            + '   |   ' + week.songs.length + ' musicas';
    }

    function move(index:Int, delta:Int):Void
    {
        var target = index + delta;
        if (target < 0 || target >= week.songs.length) return;
        var temp = week.songs[index];
        week.songs[index] = week.songs[target];
        week.songs[target] = temp;
        onChanged();
        rebuild();
    }

    function removeSong(index:Int):Void
    {
        if (index < 0 || index >= week.songs.length) return;
        week.songs.splice(index, 1);
        onChanged();
        rebuild();
    }

    function normalizeSongId(value:String):String
    {
        return Paths.formatToSongPath(value);
    }

    override function update(elapsed:Float):Void
    {
        #if android
        if (FlxG.android.justReleased.BACK)
        {
            FlxG.stage.window.textInputEnabled = false;
            close();
            return;
        }
        #end
        super.update(elapsed);
    }
}
