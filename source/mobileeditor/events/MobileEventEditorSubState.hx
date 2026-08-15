package mobileeditor.events;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import mobileeditor.MobileAssetDiscovery;
import mobileeditor.ui.MobileButton;

/**
 * Touch-first event form that edits the SAME event/value1/value2 representation
 * used by ChartingState. Known events are decoded through MobileEventRegistry;
 * unknown custom events fall back to raw Value 1 / Value 2 fields.
 */
class MobileEventEditorSubState extends MusicBeatSubstate
{
    var eventName:String;
    var originalValue1:String;
    var originalValue2:String;
    var values:Map<String, String>;
    var inputs:Map<String, FlxUIInputText> = new Map();
    var optionIndexes:Map<String, Int> = new Map();
    var dynamicButtons:Array<MobileButton> = [];
    var dynamicTexts:Array<FlxText> = [];
    var applyCallback:String->String->String->Void;
    var player:String;
    var opponent:String;
    var girlfriend:String;
    var eventNames:Array<String> = [];
    var eventIndex:Int = 0;
    var eventButton:MobileButton;
    var description:FlxText;

    public function new(name:String, value1:String, value2:String,
        player:String, opponent:String, girlfriend:String,
        applyCallback:String->String->String->Void)
    {
        super();
        this.eventName = name == null || name.length == 0 ? 'Change Character' : name;
        this.originalValue1 = value1 == null ? '' : value1;
        this.originalValue2 = value2 == null ? '' : value2;
        this.player = player;
        this.opponent = opponent;
        this.girlfriend = girlfriend;
        this.applyCallback = applyCallback;
    }

    override function create():Void
    {
        super.create();
        FlxG.mouse.visible = true;

        var shade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xE61A1D24);
        shade.scrollFactor.set();
        add(shade);

        var title = new FlxText(32, 22, FlxG.width - 64, 'EVENT EDITOR', 30);
        title.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT);
        title.scrollFactor.set();
        add(title);

        for (definition in MobileEventRegistry.list()) eventNames.push(definition.name);
        eventNames.push('Custom Event');
        eventIndex = eventNames.indexOf(eventName);
        if (eventIndex < 0) eventIndex = eventNames.length - 1;

        eventButton = new MobileButton(32, 68, FlxG.width - 64, 56, '', cycleEvent);
        eventButton.scrollFactor.set();
        add(eventButton);

        description = new FlxText(32, 132, FlxG.width - 64, '', 18);
        description.setFormat(Paths.font('vcr.ttf'), 18, 0xFFB8C3D9, LEFT);
        description.scrollFactor.set();
        add(description);

        add(new MobileButton(32, FlxG.height - 76, 180, 52, 'CANCELAR', function() close()));
        add(new MobileButton(FlxG.width - 292, FlxG.height - 76, 260, 52, 'APLICAR EVENTO', apply));

        rebuildForm(false);
    }

    function cycleEvent():Void
    {
        eventIndex = (eventIndex + 1) % eventNames.length;
        var picked = eventNames[eventIndex];
        if (picked == 'Custom Event')
        {
            if (MobileEventRegistry.has(eventName)) eventName = 'Meu Evento';
        }
        else eventName = picked;
        originalValue1 = '';
        originalValue2 = '';
        rebuildForm(true);
    }

    function rebuildForm(reset:Bool):Void
    {
        for (input in inputs) { remove(input, true); input.destroy(); }
        inputs = new Map();
        for (button in dynamicButtons) { remove(button, true); button.destroy(); }
        dynamicButtons = [];
        for (text in dynamicTexts) { remove(text, true); text.destroy(); }
        dynamicTexts = [];
        optionIndexes = new Map();

        var known = MobileEventRegistry.has(eventName);
        var def = known ? MobileEventRegistry.get(eventName) : null;
        values = reset ? new Map<String, String>() : MobileEventRegistry.decode(eventName, originalValue1, originalValue2);

        eventButton.label.text = known ? def.name + '  >' : 'CUSTOM EVENT: ' + eventName + '  >';
        description.text = known ? def.category + ' - ' + def.description : 'Evento customizado: compatibilidade por Value 1 / Value 2.';

        var y:Float = 186;
        if (!known)
        {
            addInput('eventName', 'Evento', eventName, y); y += 82;
            addInput('value1', 'Value 1', originalValue1, y); y += 82;
            addInput('value2', 'Value 2', originalValue2, y);
            return;
        }

        for (param in def.parameters)
        {
            var current = values.exists(param.id) ? values.get(param.id) : param.defaultValue;
            if (current == null) current = '';
            switch (param.kind)
            {
                case 'character-slot':
                    var options = ['dad', 'bf', 'gf'];
                    addCycle(param.id, param.label, current, options, y);
                case 'character-picker':
                    var chars = MobileAssetDiscovery.listCharacters();
                    if (chars.length == 0) chars = ['bf', 'dad', 'gf'];
                    addCycle(param.id, param.label, current, chars, y);
                case 'animation-picker':
                    var slot = values.exists('slot') ? values.get('slot') : 'dad';
                    var charId = characterForSlot(slot);
                    var animations = MobileAssetDiscovery.getCharacterInfo(charId).animations;
                    if (animations.length == 0) animations = ['idle', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
                    addCycle(param.id, param.label + ' (' + MobileAssetDiscovery.prettify(charId) + ')', current, animations, y);
                default:
                    addInput(param.id, param.label, current, y);
            }
            y += 82;
        }
    }

    function addInput(id:String, labelText:String, value:String, y:Float):Void
    {
        var label = formLabel(labelText, y);
        dynamicTexts.push(label); add(label);
        var input = new FlxUIInputText(32, y + 28, FlxG.width - 64, value, 22);
        input.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.BLACK, LEFT);
        input.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
        input.scrollFactor.set();
        inputs.set(id, input);
        add(input);
    }

    function addCycle(id:String, labelText:String, value:String, options:Array<String>, y:Float):Void
    {
        var label = formLabel(labelText, y);
        dynamicTexts.push(label); add(label);
        var index = options.indexOf(value);
        if (index < 0) index = 0;
        optionIndexes.set(id, index);
        values.set(id, options[index]);
        var button:MobileButton = null;
        button = new MobileButton(32, y + 28, FlxG.width - 64, 50, MobileAssetDiscovery.prettify(options[index]) + '  >', function() {
            var next = (optionIndexes.get(id) + 1) % options.length;
            optionIndexes.set(id, next);
            values.set(id, options[next]);
            button.label.text = MobileAssetDiscovery.prettify(options[next]) + '  >';
        });
        button.scrollFactor.set();
        dynamicButtons.push(button);
        add(button);
    }

    function formLabel(text:String, y:Float):FlxText
    {
        var label = new FlxText(32, y, FlxG.width - 64, text, 19);
        label.setFormat(Paths.font('vcr.ttf'), 19, FlxColor.WHITE, LEFT);
        label.scrollFactor.set();
        return label;
    }

    function characterForSlot(slot:String):String
    {
        switch (slot == null ? 'dad' : slot.toLowerCase())
        {
            case 'bf', 'boyfriend', 'player', '0': return player;
            case 'gf', 'girlfriend', '2': return girlfriend;
            default: return opponent;
        }
    }

    function apply():Void
    {
        FlxG.stage.window.textInputEnabled = false;
        if (!MobileEventRegistry.has(eventName))
        {
            var customName = inputs.exists('eventName') ? StringTools.trim(inputs.get('eventName').text) : eventName;
            if (customName.length == 0) customName = 'Custom Event';
            var v1 = inputs.exists('value1') ? inputs.get('value1').text : '';
            var v2 = inputs.exists('value2') ? inputs.get('value2').text : '';
            applyCallback(customName, v1, v2);
            close();
            return;
        }

        for (id => input in inputs) values.set(id, input.text);
        var encoded = MobileEventRegistry.encode(eventName, values);
        applyCallback(eventName, encoded.value1, encoded.value2);
        close();
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
