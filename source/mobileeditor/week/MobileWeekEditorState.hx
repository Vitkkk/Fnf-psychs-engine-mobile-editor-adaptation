package mobileeditor.week;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import openfl.utils.Assets;
import mobileeditor.MobileEditorSavePaths;
import mobileeditor.MobileProjectContext;
import mobileeditor.MobileSafeWriter;
import mobileeditor.ui.MobileButton;
import WeekData.WeekFile;

using StringTools;

/**
 * Dedicated touch-first Week editor. The screen itself is the preview:
 * characters/background/title/track list update immediately while editing.
 * It intentionally does not replace the classic WeekEditorState.
 */
class MobileWeekEditorState extends MusicBeatState
{
    public var week:WeekFile;
    public var weekId:String;

    var bgYellow:FlxSprite;
    var bgSprite:FlxSprite;
    var chars:FlxTypedGroup<MenuCharacter>;
    var titleInput:FlxUIInputText;
    var titlePreview:FlxText;
    var tracksText:FlxText;
    var statusText:FlxText;
    var dirty:Bool = false;

    public function new(weekId:String, week:WeekFile)
    {
        super();
        this.weekId = sanitizeId(weekId);
        this.week = week == null ? WeekData.createWeekFile() : week;
        normalizeWeek();
    }

    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;

        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

        // Story Mode-style live preview area.
        bgYellow = new FlxSprite(0, 46).makeGraphic(FlxG.width, 330, 0xFFF9CF51);
        add(bgYellow);

        bgSprite = new FlxSprite(0, 46);
        bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
        add(bgSprite);

        chars = new FlxTypedGroup<MenuCharacter>();
        add(chars);

        var editorLabel = new FlxText(22, 8, 360, 'MOBILE WEEK EDITOR', 24);
        editorLabel.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, LEFT);
        add(editorLabel);

        var project = MobileProjectContext.activeMod();
        var projectLabel = new FlxText(390, 12, FlxG.width - 410, 'MOD: ' + (project.length > 0 ? project : 'mods/'), 16);
        projectLabel.setFormat(Paths.font('vcr.ttf'), 16, 0xFFB8C3D9, RIGHT);
        add(projectLabel);

        var tracksLabel = new FlxText(40, 394, 250, 'TRACKS', 32);
        tracksLabel.setFormat(Paths.font('vcr.ttf'), 32, 0xFFE55777, CENTER);
        add(tracksLabel);

        tracksText = new FlxText(40, 438, 250, '', 23);
        tracksText.setFormat(Paths.font('vcr.ttf'), 23, 0xFFE55777, CENTER);
        add(tracksText);

        titlePreview = new FlxText(330, 405, FlxG.width - 620, '', 50);
        titlePreview.setFormat(Paths.font('vcr.ttf'), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        titlePreview.borderSize = 3;
        add(titlePreview);

        var titleLabel = new FlxText(330, 478, FlxG.width - 620, 'TITULO DA WEEK', 15);
        titleLabel.setFormat(Paths.font('vcr.ttf'), 15, 0xFFB8C3D9, LEFT);
        add(titleLabel);

        titleInput = new FlxUIInputText(330, 502, FlxG.width - 620, week.storyName, 22);
        titleInput.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.BLACK, LEFT);
        titleInput.focusGained = function() FlxG.stage.window.textInputEnabled = true;
        add(titleInput);

        var buttonY = FlxG.height - 116;
        add(new MobileButton(22, buttonY, 150, 58, '< VOLTAR', goBack));
        add(new MobileButton(188, buttonY, 200, 58, 'PERSONAGENS', openCharacters));
        add(new MobileButton(404, buttonY, 170, 58, 'MUSICAS', openSongs));
        add(new MobileButton(590, buttonY, 185, 58, 'AVANCADO', openAdvanced));
        add(new MobileButton(FlxG.width - 196, buttonY, 174, 58, 'SALVAR', saveWeek));

        statusText = new FlxText(22, FlxG.height - 48, FlxG.width - 44, '', 16);
        statusText.setFormat(Paths.font('vcr.ttf'), 16, 0xFFB8C3D9, CENTER);
        add(statusText);

        rebuildPreview();
    }

    function normalizeWeek():Void
    {
        if (week.songs == null) week.songs = [];
        if (week.weekCharacters == null) week.weekCharacters = ['dad', 'bf', 'gf'];
        while (week.weekCharacters.length < 3) week.weekCharacters.push(week.weekCharacters.length == 0 ? 'dad' : (week.weekCharacters.length == 1 ? 'bf' : 'gf'));
        if (week.weekBackground == null || week.weekBackground.length == 0) week.weekBackground = 'stage';
        if (week.storyName == null || week.storyName.length == 0) week.storyName = week.weekName;
        if (week.weekName == null || week.weekName.length == 0) week.weekName = week.storyName;
        if (week.weekBefore == null) week.weekBefore = '';
        if (week.freeplayColor == null || week.freeplayColor.length < 3) week.freeplayColor = [146, 113, 253];
    }

    function rebuildPreview():Void
    {
        reloadBackground();
        rebuildCharacters();

        titlePreview.text = week.storyName == null || week.storyName.length == 0 ? MobileAssetDiscovery.prettify(weekId).toUpperCase() : week.storyName;

        var lines:Array<String> = [];
        for (entry in week.songs)
        {
            if (entry == null) continue;
            var row:Array<Dynamic> = cast entry;
            if (row.length > 0) lines.push(Std.string(row[0]).toUpperCase());
        }
        tracksText.text = lines.length == 0 ? '(SEM MUSICA)' : lines.join('\n');
    }

    function reloadBackground():Void
    {
        bgSprite.visible = false;
        var id = week.weekBackground;
        if (id == null || id.length == 0) return;
        try
        {
            var graphic = Paths.image('menubackgrounds/' + id);
            if (graphic != null)
            {
                bgSprite.loadGraphic(graphic);
                bgSprite.setGraphicSize(FlxG.width, 330);
                bgSprite.updateHitbox();
                bgSprite.setPosition(0, 46);
                bgSprite.visible = true;
            }
        }
        catch (_:Dynamic) {}
    }

    function rebuildCharacters():Void
    {
        chars.clear();
        for (i in 0...3)
        {
            var id = week.weekCharacters[i];
            if (id == null || id.length == 0) id = i == 0 ? 'dad' : (i == 1 ? 'bf' : 'gf');
            var character = new MenuCharacter((FlxG.width * 0.25) * (1 + i) - 150, id);
            character.y = 78;
            character.antialiasing = ClientPrefs.globalAntialiasing;
            chars.add(character);
        }
    }

    function openCharacters():Void
    {
        FlxG.stage.window.textInputEnabled = false;
        openSubState(new MobileWeekCharactersSubState(week, function() {
            markDirty();
            rebuildPreview();
        }));
    }

    function openSongs():Void
    {
        FlxG.stage.window.textInputEnabled = false;
        openSubState(new MobileWeekSongsSubState(week, function() {
            markDirty();
            rebuildPreview();
        }));
    }

    function openAdvanced():Void
    {
        FlxG.stage.window.textInputEnabled = false;
        openSubState(new MobileWeekAdvancedSubState(week, weekId, function(newId:String) {
            weekId = sanitizeId(newId);
            markDirty();
            rebuildPreview();
        }));
    }

    function markDirty():Void
    {
        dirty = true;
        statusText.text = 'Alteracoes nao salvas';
    }

    function applyTextFields():Void
    {
        var shown = titleInput == null ? '' : titleInput.text.trim();
        if (shown.length > 0 && shown != week.storyName)
        {
            week.storyName = shown;
            week.weekName = shown;
            dirty = true;
        }
    }

    function saveWeek():Void
    {
        applyTextFields();
        FlxG.stage.window.textInputEnabled = false;
        var path = MobileEditorSavePaths.week(weekId);
        var ok = MobileSafeWriter.writeJsonAtomic(path, week, true);
        if (ok)
        {
            dirty = false;
            statusText.text = 'Salvo em: ' + path;
        }
        else statusText.text = 'Falha ao salvar. Verifique o mod ativo/permissoes.';
    }

    function goBack():Void
    {
        FlxG.stage.window.textInputEnabled = false;
        MusicBeatState.switchState(new MobileWeekListState());
    }

    override function update(elapsed:Float):Void
    {
        if (titleInput != null && titleInput.hasFocus)
        {
            var shown = titleInput.text.trim();
            titlePreview.text = shown.length == 0 ? MobileAssetDiscovery.prettify(weekId).toUpperCase() : shown;
        }

        #if android
        if (FlxG.android.justReleased.BACK)
        {
            goBack();
            return;
        }
        #end
        super.update(elapsed);
    }

    static function sanitizeId(value:String):String
    {
        if (value == null) return 'week';
        var text = value.trim().toLowerCase().replace(' ', '-');
        text = ~/[^a-z0-9_-]/g.replace(text, '');
        return text.length == 0 ? 'week' : text;
    }
}
