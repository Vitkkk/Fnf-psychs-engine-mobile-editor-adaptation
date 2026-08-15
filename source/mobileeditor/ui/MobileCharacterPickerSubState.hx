package mobileeditor.ui;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import mobileeditor.MobileAssetDiscovery;

/** Large searchable character picker shared by Week, Song and Event editors. */
class MobileCharacterPickerSubState extends MusicBeatSubstate
{
    static inline var PAGE_SIZE:Int = 5;

    var all:Array<String> = [];
    var filtered:Array<String> = [];
    var page:Int = 0;
    var search:FlxUIInputText;
    var lastSearch:String = '';
    var rows:Array<FlxBasic> = [];
    var pageText:FlxText;
    var onPick:String->Void;

    public function new(onPick:String->Void)
    {
        super();
        this.onPick = onPick;
    }

    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;
        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xF21A1D24));

        var title = new FlxText(28, 20, FlxG.width - 56, 'SELECIONAR PERSONAGEM', 30);
        title.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT);
        add(title);

        search = new FlxUIInputText(28, 68, FlxG.width - 56, '', 22);
        search.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.BLACK, LEFT);
        search.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
        add(search);

        var hint = new FlxText(32, 102, FlxG.width - 64, 'Pesquisar por nome ou ID', 16);
        hint.setFormat(Paths.font('vcr.ttf'), 16, 0xFFB8C3D9, LEFT);
        add(hint);

        pageText = new FlxText(FlxG.width / 2 - 150, FlxG.height - 64, 300, '', 18);
        pageText.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, CENTER);
        add(pageText);

        add(new MobileButton(28, FlxG.height - 72, 150, 48, '< VOLTAR', function() {
            FlxG.stage.window.textInputEnabled = false;
            close();
        }));
        add(new MobileButton(196, FlxG.height - 72, 150, 48, '< PAG', function() {
            if (page > 0) { page--; rebuildRows(); }
        }));
        add(new MobileButton(FlxG.width - 178, FlxG.height - 72, 150, 48, 'PAG >', function() {
            if ((page + 1) * PAGE_SIZE < filtered.length) { page++; rebuildRows(); }
        }));

        all = MobileAssetDiscovery.listCharacters();
        applyFilter();
    }

    function applyFilter():Void
    {
        var query = StringTools.trim(search.text).toLowerCase();
        filtered = [];
        for (id in all)
        {
            var pretty = MobileAssetDiscovery.prettify(id).toLowerCase();
            if (query.length == 0 || id.toLowerCase().indexOf(query) >= 0 || pretty.indexOf(query) >= 0)
                filtered.push(id);
        }
        page = 0;
        rebuildRows();
    }

    function rebuildRows():Void
    {
        for (item in rows) { remove(item, true); item.destroy(); }
        rows = [];

        var start = page * PAGE_SIZE;
        var end = Std.int(Math.min(start + PAGE_SIZE, filtered.length));
        var y:Float = 132;
        for (i in start...end)
        {
            var id = filtered[i];
            var info = MobileAssetDiscovery.getCharacterInfo(id);

            var icon = new HealthIcon(info.healthIcon, false);
            icon.setGraphicSize(64, 64);
            icon.updateHitbox();
            icon.setPosition(42, y + 4);
            icon.scrollFactor.set();
            rows.push(icon); add(icon);

            var subtitle = info.source == 'mod' ? 'MOD' : info.source.toUpperCase();
            var button = new MobileButton(116, y, FlxG.width - 154, 70,
                info.displayName + '   [' + id + ']   ' + subtitle, function() pick(id));
            button.scrollFactor.set();
            rows.push(button); add(button);
            y += 80;
        }

        if (filtered.length == 0)
        {
            var empty = new FlxText(28, 160, FlxG.width - 56, 'Nenhum personagem encontrado.', 22);
            empty.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.WHITE, CENTER);
            rows.push(empty); add(empty);
        }

        var pages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
        pageText.text = 'Pagina ' + (page + 1) + ' / ' + pages + '   |   ' + filtered.length + ' personagens';
    }

    function pick(id:String):Void
    {
        FlxG.stage.window.textInputEnabled = false;
        onPick(id);
        close();
    }

    override function update(elapsed:Float):Void
    {
        if (search.text != lastSearch)
        {
            lastSearch = search.text;
            applyFilter();
        }
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
