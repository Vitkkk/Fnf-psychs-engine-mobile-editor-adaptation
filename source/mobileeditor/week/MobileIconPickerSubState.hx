package mobileeditor.week;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import mobileeditor.MobileAssetDiscovery;
import mobileeditor.ui.MobileButton;

/** Visual HealthIcon chooser. No internal icon ID has to be typed. */
class MobileIconPickerSubState extends MusicBeatSubstate
{
    static inline var ITEMS_PER_PAGE:Int = 5;
    var icons:Array<String> = [];
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
        var title = new FlxText(28, 20, FlxG.width - 56, 'ESCOLHER ICONE', 30);
        title.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT);
        add(title);

        icons = MobileAssetDiscovery.listIcons();
        pageText = new FlxText(360, FlxG.height - 64, FlxG.width - 720, '', 18);
        pageText.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, CENTER);
        add(pageText);

        add(new MobileButton(28, FlxG.height - 72, 150, 48, '< VOLTAR', close));
        add(new MobileButton(194, FlxG.height - 72, 130, 48, '< PAG', function() {
            if (page > 0) { page--; rebuild(); }
        }));
        add(new MobileButton(FlxG.width - 158, FlxG.height - 72, 130, 48, 'PAG >', function() {
            if ((page + 1) * ITEMS_PER_PAGE < icons.length) { page++; rebuild(); }
        }));
        rebuild();
    }

    function rebuild():Void
    {
        for (item in rows) { remove(item, true); item.destroy(); }
        rows = [];
        var start = page * ITEMS_PER_PAGE;
        var end = Std.int(Math.min(start + ITEMS_PER_PAGE, icons.length));
        var y:Float = 88;
        for (i in start...end)
        {
            var id = icons[i];
            var icon = new HealthIcon(id, false);
            icon.setGraphicSize(78, 78);
            icon.updateHitbox();
            icon.setPosition(48, y + 5);
            rows.push(icon); add(icon);

            var captured = id;
            var button = new MobileButton(144, y + 10, FlxG.width - 192, 62,
                MobileAssetDiscovery.prettify(id) + '   [' + id + ']', function() {
                    onSelect(captured);
                    close();
                });
            rows.push(button); add(button);
            y += 88;
        }
        pageText.text = 'Pagina ' + (page + 1) + ' / ' + Math.max(1, Math.ceil(icons.length / ITEMS_PER_PAGE));
    }

    override function update(elapsed:Float):Void
    {
        #if android
        if (FlxG.android.justReleased.BACK) { close(); return; }
        #end
        super.update(elapsed);
    }
}
