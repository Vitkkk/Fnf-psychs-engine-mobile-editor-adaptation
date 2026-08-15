package mobileeditor.week;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import editors.WeekEditorState;
import mobileeditor.ui.MobileButton;
import WeekData.WeekFile;

/**
 * First step of the mobile Week creation flow.
 * Collects only the two names that genuinely need text input, then hands the
 * real WeekFile to the existing editor so every saved field stays compatible.
 */
class MobileWeekCreateState extends MusicBeatState
{
    var internalName:FlxUIInputText;
    var displayName:FlxUIInputText;
    var errorText:FlxText;

    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;

        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF171A20));

        var title = new FlxText(36, 28, FlxG.width - 72, 'CRIAR WEEK', 34);
        title.setFormat(Paths.font('vcr.ttf'), 34, FlxColor.WHITE, LEFT);
        add(title);

        var help = new FlxText(36, 78, FlxG.width - 72,
            'Defina os nomes da week. Os outros campos serao configurados visualmente em seguida.', 19);
        help.setFormat(Paths.font('vcr.ttf'), 19, 0xFFB8C3D9, LEFT);
        add(help);

        add(label('Nome interno', 36, 146));
        internalName = new FlxUIInputText(36, 180, FlxG.width - 72, 'minha-week', 24);
        internalName.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.BLACK, LEFT);
        internalName.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
        add(internalName);

        add(label('Titulo exibido', 36, 252));
        displayName = new FlxUIInputText(36, 286, FlxG.width - 72, 'MINHA WEEK', 24);
        displayName.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.BLACK, LEFT);
        displayName.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
        add(displayName);

        errorText = new FlxText(36, 350, FlxG.width - 72, '', 18);
        errorText.setFormat(Paths.font('vcr.ttf'), 18, 0xFFFF7070, LEFT);
        add(errorText);

        add(new MobileButton(36, FlxG.height - 84, 190, 56, '< VOLTAR', function() {
            MusicBeatState.switchState(new MobileWeekListState());
        }));

        add(new MobileButton(FlxG.width - 316, FlxG.height - 84, 280, 56, 'CONTINUAR >', continueCreate));
    }

    function label(text:String, x:Float, y:Float):FlxText
    {
        var out = new FlxText(x, y, FlxG.width - 72, text, 21);
        out.setFormat(Paths.font('vcr.ttf'), 21, FlxColor.WHITE, LEFT);
        return out;
    }

    function continueCreate():Void
    {
        var id = sanitizeId(internalName.text);
        var shown = StringTools.trim(displayName.text);
        if (id.length < 1)
        {
            errorText.text = 'Informe um nome interno valido.';
            return;
        }
        if (shown.length < 1) shown = id.toUpperCase();

        var week:WeekFile = WeekData.createWeekFile();
        week.weekName = shown;
        week.storyName = shown;
        WeekEditorState.weekFileName = id;
        FlxG.stage.window.textInputEnabled = false;
        MusicBeatState.switchState(new WeekEditorState(week));
    }

    function sanitizeId(value:String):String
    {
        var text = StringTools.trim(value).toLowerCase();
        text = StringTools.replace(text, ' ', '-');
        var allowed = ~/[^a-z0-9_-]/g;
        return allowed.replace(text, '');
    }

    override function update(elapsed:Float):Void
    {
        #if android
        if (FlxG.android.justReleased.BACK)
        {
            FlxG.stage.window.textInputEnabled = false;
            MusicBeatState.switchState(new MobileWeekListState());
            return;
        }
        #end
        super.update(elapsed);
    }
}
