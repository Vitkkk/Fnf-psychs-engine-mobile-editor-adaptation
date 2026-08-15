package mobileeditor.chart;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import mobileeditor.MobileAssetDiscovery;
import mobileeditor.ui.MobileButton;
import mobileeditor.ui.MobileCharacterPickerSubState;

/** Touch-first Player / Opponent / GF selector for ChartingState song data. */
class MobileChartCharactersSubState extends MusicBeatSubstate
{
    var player:String;
    var opponent:String;
    var girlfriend:String;
    var onApply:String->String->String->Void;
    var items:Array<FlxBasic> = [];

    public function new(player:String, opponent:String, girlfriend:String, onApply:String->String->String->Void)
    {
        super();
        this.player = player;
        this.opponent = opponent;
        this.girlfriend = girlfriend;
        this.onApply = onApply;
    }

    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;
        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xF21A1D24));

        var title = new FlxText(30, 22, FlxG.width - 60, 'PERSONAGENS DA MUSICA', 30);
        title.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT);
        add(title);

        var hint = new FlxText(30, 62, FlxG.width - 60,
            'Escolha visualmente Player, Opponent e GF. Os IDs reais continuam sendo salvos no song JSON.', 17);
        hint.setFormat(Paths.font('vcr.ttf'), 17, 0xFFB8C3D9, LEFT);
        add(hint);

        add(new MobileButton(30, FlxG.height - 72, 180, 48, 'CANCELAR', close));
        add(new MobileButton(FlxG.width - 250, FlxG.height - 72, 220, 48, 'APLICAR', function() {
            onApply(player, opponent, girlfriend);
            close();
        }));
        rebuild();
    }

    function rebuild():Void
    {
        for (item in items) { remove(item, true); item.destroy(); }
        items = [];

        var labels = ['PLAYER', 'OPPONENT', 'GF'];
        var ids = [player, opponent, girlfriend];
        var y:Float = 118;

        for (i in 0...3)
        {
            var id = ids[i];
            var info = MobileAssetDiscovery.getCharacterInfo(id);
            var card = new FlxSprite(28, y).makeGraphic(FlxG.width - 56, 126, 0xFF262B35);
            items.push(card); add(card);

            var icon = new HealthIcon(info.healthIcon, i == 0);
            icon.setGraphicSize(96, 96); icon.updateHitbox();
            icon.setPosition(46, y + 15); icon.scrollFactor.set();
            items.push(icon); add(icon);

            var slot = new FlxText(158, y + 14, FlxG.width - 440, labels[i], 17);
            slot.setFormat(Paths.font('vcr.ttf'), 17, 0xFF8FA4C9, LEFT);
            items.push(slot); add(slot);

            var name = new FlxText(158, y + 42, FlxG.width - 440, info.displayName + '  [' + id + ']', 23);
            name.setFormat(Paths.font('vcr.ttf'), 23, FlxColor.WHITE, LEFT);
            items.push(name); add(name);

            var source = new FlxText(158, y + 78, FlxG.width - 440,
                info.source.toUpperCase() + '  |  ' + info.animations.length + ' animacoes', 15);
            source.setFormat(Paths.font('vcr.ttf'), 15, 0xFFB8C3D9, LEFT);
            items.push(source); add(source);

            var captured = i;
            var change = new MobileButton(FlxG.width - 250, y + 35, 200, 56, 'ALTERAR', function() {
                openSubState(new MobileCharacterPickerSubState(function(selected:String) {
                    switch (captured) {
                        case 0: player = selected;
                        case 1: opponent = selected;
                        case 2: girlfriend = selected;
                    }
                    rebuild();
                }));
            });
            items.push(change); add(change);
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
