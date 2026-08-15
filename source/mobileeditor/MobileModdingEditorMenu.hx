package mobileeditor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import mobileeditor.ui.MobileButton;
import mobileeditor.week.MobileWeekListState;

/** Entry point kept separate from Psych Engine's original editor menu. */
class MobileModdingEditorMenu extends MusicBeatState
{
    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;
        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF171A20));

        var title = new FlxText(36, 30, FlxG.width - 72, 'MOBILE MODDING EDITORS', 36);
        title.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.WHITE, LEFT);
        add(title);

        var subtitle = new FlxText(36, 82, FlxG.width - 72,
            'Editores feitos para touchscreen. Os editores originais continuam separados.', 19);
        subtitle.setFormat(Paths.font('vcr.ttf'), 19, 0xFFB8C3D9, LEFT);
        add(subtitle);

        add(new MobileButton(50, 150, FlxG.width - 100, 82, 'MOBILE WEEK EDITOR', function() {
            MusicBeatState.switchState(new MobileWeekListState());
        }));

        var future = new FlxText(50, 270, FlxG.width - 100,
            'Chart Editor Mobile - futuramente\nCharacter Editor Mobile - futuramente\nStage Editor Mobile - futuramente', 24);
        future.setFormat(Paths.font('vcr.ttf'), 24, 0xFF6F788A, LEFT);
        add(future);

        add(new MobileButton(36, FlxG.height - 84, 190, 56, '< VOLTAR', function() {
            MusicBeatState.switchState(new editors.MasterEditorMenu());
        }));
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
