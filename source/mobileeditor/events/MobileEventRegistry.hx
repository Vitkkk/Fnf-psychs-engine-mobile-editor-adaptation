package mobileeditor.events;

using StringTools;

class MobileEventRegistry
{
    static var definitions:Map<String, MobileEventDefinition> = build();

    static function build():Map<String, MobileEventDefinition>
    {
        var map:Map<String, MobileEventDefinition> = new Map();

        map.set('Change Character', new MobileEventDefinition(
            'Change Character', 'Character', 'Switch Player, Opponent or GF to another installed character.',
            [
                {id:'slot', label:'Character slot', kind:'character-slot', defaultValue:'dad', options:['bf','dad','gf']},
                {id:'character', label:'Switch to', kind:'character-picker', defaultValue:'bf'}
            ],
            function(v) return {value1: normalizeSlot(v.get('slot')), value2: safe(v.get('character'))},
            function(value1, value2) {
                var out = new Map<String, String>();
                out.set('slot', normalizeSlot(value1)); out.set('character', value2); return out;
            }
        ));

        map.set('Screen Shake', new MobileEventDefinition(
            'Screen Shake', 'Screen', 'Shake gameplay and HUD cameras independently.',
            [
                {id:'gameDuration', label:'Game duration', kind:'seconds', defaultValue:'0'},
                {id:'gameIntensity', label:'Game intensity', kind:'float', defaultValue:'0'},
                {id:'hudDuration', label:'HUD duration', kind:'seconds', defaultValue:'0'},
                {id:'hudIntensity', label:'HUD intensity', kind:'float', defaultValue:'0'}
            ],
            function(v) return {
                value1: pair(v.get('gameDuration'), v.get('gameIntensity')),
                value2: pair(v.get('hudDuration'), v.get('hudIntensity'))
            },
            function(value1, value2) {
                var out = new Map<String, String>();
                var a = splitPair(value1); var b = splitPair(value2);
                out.set('gameDuration', a[0]); out.set('gameIntensity', a[1]);
                out.set('hudDuration', b[0]); out.set('hudIntensity', b[1]); return out;
            }
        ));

        map.set('Camera Follow Pos', new MobileEventDefinition(
            'Camera Follow Pos', 'Camera', 'Move the camera follow point. Blank values restore normal follow behavior.',
            [
                {id:'x', label:'X', kind:'float', defaultValue:''},
                {id:'y', label:'Y', kind:'float', defaultValue:''}
            ],
            function(v) return {value1:safe(v.get('x')), value2:safe(v.get('y'))},
            function(value1, value2) {
                var out = new Map<String, String>(); out.set('x', value1); out.set('y', value2); return out;
            }
        ));

        map.set('Play Animation', new MobileEventDefinition(
            'Play Animation', 'Character', 'Play one animation on Player, Opponent or GF.',
            [
                {id:'animation', label:'Animation', kind:'animation-picker', defaultValue:'idle'},
                {id:'slot', label:'Character', kind:'character-slot', defaultValue:'dad', options:['bf','dad','gf']}
            ],
            function(v) return {value1:safe(v.get('animation')), value2:normalizeSlot(v.get('slot'))},
            function(value1, value2) {
                var out = new Map<String, String>(); out.set('animation', value1); out.set('slot', normalizeSlot(value2)); return out;
            }
        ));

        // This port exposes Super Flash rather than the newer generic flash event.
        map.set('Super Flash', new MobileEventDefinition(
            'Super Flash', 'Screen', 'Flash the screen using the port-compatible Super Flash event.',
            [
                {id:'duration', label:'Duration', kind:'seconds', defaultValue:'0.5'}
            ],
            function(v) return {value1:safe(v.get('duration')), value2:''},
            function(value1, value2) {
                var out = new Map<String, String>(); out.set('duration', value1); return out;
            }
        ));

        return map;
    }

    public static function get(name:String):MobileEventDefinition return definitions.get(name);
    public static function has(name:String):Bool return definitions.exists(name);

    public static function list(?category:String):Array<MobileEventDefinition>
    {
        var out:Array<MobileEventDefinition> = [];
        for (definition in definitions)
            if (category == null || category.length == 0 || definition.category == category) out.push(definition);
        out.sort(function(a, b) return Reflect.compare(a.name, b.name));
        return out;
    }

    public static function encode(name:String, values:Map<String, String>):MobileEventValues
    {
        var definition = get(name);
        if (definition == null) return {value1:safe(values.get('value1')), value2:safe(values.get('value2'))};
        return definition.encode(values);
    }

    public static function decode(name:String, value1:String, value2:String):Map<String, String>
    {
        var definition = get(name);
        if (definition == null) {
            var out = new Map<String, String>(); out.set('value1', safe(value1)); out.set('value2', safe(value2)); return out;
        }
        return definition.decode(safe(value1), safe(value2));
    }

    static function normalizeSlot(value:String):String
    {
        if (value == null) return 'dad';
        switch (value.toLowerCase().trim()) {
            case '0', 'bf', 'boyfriend', 'player': return 'bf';
            case '1', 'dad', 'opponent': return 'dad';
            case '2', 'gf', 'girlfriend': return 'gf';
            default: return value.trim();
        }
    }

    static function pair(a:String, b:String):String return safe(a) + ', ' + safe(b);
    static function splitPair(value:String):Array<String>
    {
        var pieces = safe(value).split(',');
        var a = pieces.length > 0 ? pieces[0].trim() : '';
        var b = pieces.length > 1 ? pieces[1].trim() : '';
        return [a, b];
    }
    static function safe(value:String):String return value == null ? '' : value.trim();
}
