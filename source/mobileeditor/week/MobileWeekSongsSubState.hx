package mobileeditor.week;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import mobileeditor.MobileAssetDiscovery;
import mobileeditor.ui.MobileButton;
import WeekData.WeekFile;

/** Touch-first editor for WeekFile.songs with visual song + icon selection. */
class MobileWeekSongsSubState extends MusicBeatSubstate
{
    static inline var ITEMS_PER_PAGE:Int = 4;

    var week:WeekFile;
    var onChanged:Void->Void;
    var page:Int = 0;
    var rows:Array<FlxBasic> = [];
    var pageText:FlxText;

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

        var hint = new FlxText(28, 58, FlxG.width - 300,
            'Selecione musicas e icones encontrados automaticamente.', 16);
        hint.setFormat(Paths.font('vcr.ttf'), 16, 0xFFB8C3D9, LEFT);
        add(hint);

        add(new MobileButton(FlxG.width - 268, 20, 240, 56, '+ ADICIONAR MUSICA', addSongVisual));

        pageText = new FlxText(FlxG.width / 2 - 180, FlxG.height - 62, 360, '', 18);
        pageText.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, CENTER);
        add(pageText);

        add(new MobileButton(28, FlxG.height - 72, 150, 48, '< VOLTAR', close));
        add(new MobileButton(194, FlxG.height - 72, 130, 48, '< PAG', function() {
            if (page > 0) { page--; rebuild(); }
        }));
        add(new MobileButton(FlxG.width - 158, FlxG.height - 72, 130, 48, 'PAG >', function() {
            if ((page + 1) * ITEMS_PER_PAGE < week.songs.length) { page++; rebuild(); }
        }));

        rebuild();
    }

    function addSongVisual():Void
    {
        openSubState(new MobileSongPickerSubState(function(songId:String) {
            openSubState(new MobileIconPickerSubState(function(iconId:String) {
                var display = MobileAssetDiscovery.prettify(songId);
                week.songs.push([display, iconId, [146, 113, 253], display]);
                page = Std.int((week.songs.length - 1) / ITEMS_PER_PAGE);
                onChanged();
                rebuild();
            }));
        }));
    }

    function rebuild():Void
    {
        for (item in rows) { remove(item, true); item.destroy(); }
        rows = [];

        var maxPage = week.songs.length == 0 ? 0 : Std.int((week.songs.length - 1) / ITEMS_PER_PAGE);
        if (page > maxPage) page = maxPage;
        var start = page * ITEMS_PER_PAGE;
        var end = Std.int(Math.min(start + ITEMS_PER_PAGE, week.songs.length));
        var y:Float = 96;

        for (i in start...end)
        {
            var index = i;
            var entry:Array<Dynamic> = cast week.songs[index];
            while (entry.length < 4) entry.push(entry.length == 1 ? 'dad' : (entry.length == 2 ? [146, 113, 253] : Std.string(entry[0])));
            var name = Std.string(entry[0]);
            var iconId = Std.string(entry[1]);

            var card = new FlxSprite(28, y).makeGraphic(FlxG.width - 56, 112, 0xFF262B35);
            rows.push(card); add(card);

            var icon = new HealthIcon(iconId, false);
            icon.setGraphicSize(78, 78);
            icon.updateHitbox();
            icon.setPosition(42, y + 17);
            rows.push(icon); add(icon);

            var title = new FlxText(132, y + 14, FlxG.width - 720, name, 22);
            title.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.WHITE, LEFT);
            rows.push(title); add(title);

            var subtitle = new FlxText(132, y + 48, FlxG.width - 720,
                'Song ID: ' + Paths.formatToSongPath(name) + '  |  Icone: ' + iconId, 14);
            subtitle.setFormat(Paths.font('vcr.ttf'), 14, 0xFFB8C3D9, LEFT);
            rows.push(subtitle); add(subtitle);

            var captured = index;
            var iconButton = new MobileButton(FlxG.width - 570, y + 28, 154, 52, 'ICONE', function() changeIcon(captured));
            rows.push(iconButton); add(iconButton);
            var up = new MobileButton(FlxG.width - 402, y + 28, 74, 52, 'UP', function() move(captured, -1));
            rows.push(up); add(up);
            var down = new MobileButton(FlxG.width - 316, y + 28, 86, 52, 'DOWN', function() move(captured, 1));
            rows.push(down); add(down);
            var removeButton = new MobileButton(FlxG.width - 218, y + 28, 166, 52, 'REMOVER', function() removeSong(captured));
            rows.push(removeButton); add(removeButton);
            y += 122;
        }

        if (week.songs.length == 0)
        {
            var empty = new FlxText(28, 180, FlxG.width - 56,
                'Nenhuma musica. Toque em + ADICIONAR MUSICA.', 22);
            empty.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.WHITE, CENTER);
            rows.push(empty); add(empty);
        }

        pageText.text = 'Pagina ' + (page + 1) + ' / ' + Math.max(1, Math.ceil(week.songs.length / ITEMS_PER_PAGE))
            + '   |   ' + week.songs.length + ' musicas';
    }

    function changeIcon(index:Int):Void
    {
        if (index < 0 || index >= week.songs.length) return;
        openSubState(new MobileIconPickerSubState(function(iconId:String) {
            var entry:Array<Dynamic> = cast week.songs[index];
            while (entry.length < 2) entry.push('dad');
            entry[1] = iconId;
            onChanged();
            rebuild();
        }));
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

    override function update(elapsed:Float):Void
    {
        #if android
        if (FlxG.android.justReleased.BACK) { close(); return; }
        #end
        super.update(elapsed);
    }
}
