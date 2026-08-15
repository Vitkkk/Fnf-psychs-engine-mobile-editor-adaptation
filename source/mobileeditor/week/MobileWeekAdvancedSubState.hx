package mobileeditor.week;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import mobileeditor.ui.MobileButton;
import WeekData.WeekFile;

using StringTools;

/** Less-used Psych Engine WeekFile fields, kept off the main touch screen. */
class MobileWeekAdvancedSubState extends MusicBeatSubstate
{
    var week:WeekFile;
    var weekId:String;
    var onChanged:String->Void;

    var idInput:FlxUIInputText;
    var backgroundInput:FlxUIInputText;
    var beforeInput:FlxUIInputText;
    var unlocked:FlxUICheckBox;
    var hideStory:FlxUICheckBox;
    var hideFreeplay:FlxUICheckBox;

    public function new(week:WeekFile, weekId:String, onChanged:String->Void)
    {
        super();
        this.week = week;
        this.weekId = weekId;
        this.onChanged = onChanged;
    }

    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;
        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xF21A1D24));

        var title = new FlxText(30, 22, FlxG.width - 60, 'CONFIGURACOES AVANCADAS', 30);
        title.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT);
        add(title);

        add(makeLabel('ID / arquivo da Week', 30, 82));
        idInput = makeInput(30, 108, 430, weekId);
        add(idInput);

        add(makeLabel('Background do Story Menu', 500, 82));
        backgroundInput = makeInput(500, 108, FlxG.width - 530, week.weekBackground);
        add(backgroundInput);

        add(makeLabel('Week anterior necessaria para desbloquear', 30, 190));
        beforeInput = makeInput(30, 216, 430, week.weekBefore);
        add(beforeInput);

        unlocked = new FlxUICheckBox(30, 306, null, null, 'Comeca desbloqueada', 260);
        unlocked.checked = week.startUnlocked;
        add(unlocked);

        hideStory = new FlxUICheckBox(30, 358, null, null, 'Ocultar do Story Mode', 260);
        hideStory.checked = week.hideStoryMode;
        add(hideStory);

        hideFreeplay = new FlxUICheckBox(30, 410, null, null, 'Ocultar do Freeplay', 260);
        hideFreeplay.checked = week.hideFreeplay;
        add(hideFreeplay);

        var info = new FlxText(500, 190, FlxG.width - 530,
            'Campos expostos aqui existem no WeekFile deste port.\n\nshowcutscene/currentcutscene foram mantidos no JSON e nao sao alterados por esta tela.', 17);
        info.setFormat(Paths.font('vcr.ttf'), 17, 0xFFB8C3D9, LEFT);
        add(info);

        add(new MobileButton(30, FlxG.height - 78, 190, 52, '< CANCELAR', function() {
            FlxG.stage.window.textInputEnabled = false;
            close();
        }));

        add(new MobileButton(FlxG.width - 250, FlxG.height - 78, 220, 52, 'APLICAR', applyAndClose));
    }

    function makeLabel(text:String, x:Float, y:Float):FlxText
    {
        var out = new FlxText(x, y, FlxG.width - x - 30, text, 18);
        out.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, LEFT);
        return out;
    }

    function makeInput(x:Float, y:Float, width:Int, value:String):FlxUIInputText
    {
        var input = new FlxUIInputText(x, y, width, value == null ? '' : value, 21);
        input.setFormat(Paths.font('vcr.ttf'), 21, FlxColor.BLACK, LEFT);
        input.focusGained = function() FlxG.stage.window.textInputEnabled = true;
        return input;
    }

    function applyAndClose():Void
    {
        week.weekBackground = backgroundInput.text.trim();
        if (week.weekBackground.length == 0) week.weekBackground = 'stage';
        week.weekBefore = beforeInput.text.trim();
        week.startUnlocked = unlocked.checked;
        week.hideStoryMode = hideStory.checked;
        week.hideFreeplay = hideFreeplay.checked;

        var newId = sanitizeId(idInput.text);
        FlxG.stage.window.textInputEnabled = false;
        onChanged(newId);
        close();
    }

    function sanitizeId(value:String):String
    {
        var text = value == null ? '' : value.trim().toLowerCase().replace(' ', '-');
        text = ~/[^a-z0-9_-]/g.replace(text, '');
        return text.length == 0 ? weekId : text;
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
