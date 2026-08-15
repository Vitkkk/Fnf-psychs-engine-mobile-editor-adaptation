package mobileeditor.week;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import mobileeditor.MobileAssetDiscovery;
import mobileeditor.ui.MobileButton;
import mobileeditor.ui.MobileCharacterPickerSubState;
import WeekData.WeekFile;

/** Visual three-slot Week character editor backed by WeekFile.weekCharacters. */
class MobileWeekCharactersSubState extends MusicBeatSubstate
{
    var week:WeekFile;
    var onChanged:Void->Void;
    var slotItems:Array<FlxBasic> = [];

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

        var title = new FlxText(30, 22, FlxG.width - 60, 'PERSONAGENS DA WEEK', 30);
        title.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT);
        add(title);

        var hint = new FlxText(30, 62, FlxG.width - 60,
            'Toque em Alterar para escolher visualmente entre os personagens da engine e do mod atual.', 17);
        hint.setFormat(Paths.font('vcr.ttf'), 17, 0xFFB8C3D9, LEFT);
        add(hint);

        add(new MobileButton(30, FlxG.height - 72, 190, 48, '< VOLTAR', close));
        rebuild();
    }

    function rebuild():Void
    {
        for (item in slotItems) { remove(item, true); item.destroy(); }
        slotItems = [];

        while (week.weekCharacters.length < 3) week.weekCharacters.push('');
        var slotNames = ['OPPONENT', 'PLAYER', 'GF'];
        var y:Float = 118;
        for (index in 0...3)
        {
            var id = week.weekCharacters[index];
            if (id == null || id.length == 0) id = index == 0 ? 'dad' : (index == 1 ? 'bf' : 'gf');
            var info = MobileAssetDiscovery.getCharacterInfo(id);

            var card = new FlxSprite(28, y).makeGraphic(FlxG.width - 56, 126, 0xFF262B35);
            card.scrollFactor.set(); slotItems.push(card); add(card);

            var icon = new HealthIcon(info.healthIcon, index == 1);
            icon.setGraphicSize(96, 96); icon.updateHitbox();
            icon.setPosition(46, y + 15); icon.scrollFactor.set();
            slotItems.push(icon); add(icon);

            var slot = new FlxText(158, y + 14, FlxG.width - 440, slotNames[index], 17);
            slot.setFormat(Paths.font('vcr.ttf'), 17, 0xFF8FA4C9, LEFT);
            slotItems.push(slot); add(slot);

            var name = new FlxText(158, y + 42, FlxG.width - 440,
                info.displayName + '  [' + id + ']', 23);
            name.setFormat(Paths.font('vcr.ttf'), 23, FlxColor.WHITE, LEFT);
            slotItems.push(name); add(name);

            var source = new FlxText(158, y + 78, FlxG.width - 440,
                'Fonte: ' + info.source + '  |  ' + info.animations.length + ' animacoes', 15);
            source.setFormat(Paths.font('vcr.ttf'), 15, 0xFFB8C3D9, LEFT);
            slotItems.push(source); add(source);

            var captured = index;
            var change = new MobileButton(FlxG.width - 250, y + 35, 200, 56, 'ALTERAR', function() {
                openSubState(new MobileCharacterPickerSubState(function(selected:String) {
                    week.weekCharacters[captured] = selected;
                    onChanged();
                    rebuild();
                }));
            });
            change.scrollFactor.set(); slotItems.push(change); add(change);
            y += 140;
        }
    }

    override function update(elapsed:Float):Void
    {
        #if android
        if (FlxG.android.justReleased.BACK)
        {
            close();
            return;
        }
        #end
        super.update(elapsed);
    }
}
