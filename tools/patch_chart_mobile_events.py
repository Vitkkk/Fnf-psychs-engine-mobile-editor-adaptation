from pathlib import Path
import re

p = Path('source/editors/ChartingState.hx')
s = p.read_text()

old = "import mobileeditor.MobileSafeWriter;\nimport mobileeditor.MobileEditorSavePaths;"
new = "import mobileeditor.MobileSafeWriter;\nimport mobileeditor.MobileEditorSavePaths;\n#if android\nimport mobileeditor.events.MobileEventEditorSubState;\nimport mobileeditor.chart.MobileChartCharactersSubState;\nimport mobileeditor.ui.MobileButton;\n#end"
if 'MobileEventEditorSubState' not in s:
    if old not in s:
        raise SystemExit('import anchor missing')
    s = s.replace(old, new, 1)
elif 'import mobileeditor.chart.MobileChartCharactersSubState;' not in s:
    s = s.replace('import mobileeditor.events.MobileEventEditorSubState;',
                  'import mobileeditor.events.MobileEventEditorSubState;\nimport mobileeditor.chart.MobileChartCharactersSubState;', 1)

if "'+ EVENTO', openMobileEventEditor" not in s:
    match = re.search(r'(?m)^[ \t]*this\.add\(_pad\);[ \t]*$', s)
    if match is None:
        raise SystemExit('create anchor missing')
    insert = "\n\n\t\t#if android\n\t\tvar mobileCharactersButton = new MobileButton(FlxG.width - 610, FlxG.height - 72, 280, 52, 'PERSONAGENS', openMobileChartCharacters);\n\t\tmobileCharactersButton.scrollFactor.set();\n\t\tadd(mobileCharactersButton);\n\t\tvar mobileEventButton = new MobileButton(FlxG.width - 310, FlxG.height - 72, 280, 52, '+ EVENTO', openMobileEventEditor);\n\t\tmobileEventButton.scrollFactor.set();\n\t\tadd(mobileEventButton);\n\t\t#end"
    s = s[:match.end()] + insert + s[match.end():]
elif "'PERSONAGENS', openMobileChartCharacters" not in s:
    event_button = "\t\tvar mobileEventButton = new MobileButton(FlxG.width - 310, FlxG.height - 72, 280, 52, '+ EVENTO', openMobileEventEditor);"
    chars_button = "\t\tvar mobileCharactersButton = new MobileButton(FlxG.width - 610, FlxG.height - 72, 280, 52, 'PERSONAGENS', openMobileChartCharacters);\n\t\tmobileCharactersButton.scrollFactor.set();\n\t\tadd(mobileCharactersButton);\n" + event_button
    if event_button not in s:
        raise SystemExit('event button anchor missing')
    s = s.replace(event_button, chars_button, 1)

method_anchor = "\n\tfunction updateZoom() {"
method = '''

\t#if android
\tfunction openMobileEventEditor():Void
\t{
\t\tvar editingEvent:Bool = curSelectedNote != null && curSelectedNote[1] < 0;
\t\tvar name:String = editingEvent ? Std.string(curSelectedNote[2]) : 'Change Character';
\t\tvar value1:String = editingEvent && curSelectedNote.length > 3 ? Std.string(curSelectedNote[3]) : '';
\t\tvar value2:String = editingEvent && curSelectedNote.length > 4 ? Std.string(curSelectedNote[4]) : '';

\t\topenSubState(new MobileEventEditorSubState(name, value1, value2,
\t\t\t_song.player1, _song.player2, _song.player3,
\t\t\tfunction(newName:String, newValue1:String, newValue2:String)
\t\t\t{
\t\t\t\tif (editingEvent)
\t\t\t\t{
\t\t\t\t\tcurSelectedNote[2] = newName;
\t\t\t\t\tcurSelectedNote[3] = newValue1;
\t\t\t\t\tcurSelectedNote[4] = newValue2;
\t\t\t\t}
\t\t\t\telse
\t\t\t\t{
\t\t\t\t\tvar eventNote:Array<Dynamic> = [Conductor.songPosition, -1, newName, newValue1, newValue2];
\t\t\t\t\t_song.notes[curSection].sectionNotes.push(eventNote);
\t\t\t\t\tcurSelectedNote = eventNote;
\t\t\t\t}
\t\t\t\tupdateGrid();
\t\t\t}));
\t}

\tfunction openMobileChartCharacters():Void
\t{
\t\topenSubState(new MobileChartCharactersSubState(_song.player1, _song.player2, _song.player3,
\t\t\tfunction(player:String, opponent:String, girlfriend:String)
\t\t\t{
\t\t\t\t_song.player1 = player;
\t\t\t\t_song.player2 = opponent;
\t\t\t\t_song.player3 = girlfriend;
\t\t\t\tupdateHeads();
\t\t\t}));
\t}
\t#end
'''
if 'function openMobileEventEditor():Void' not in s:
    if method_anchor not in s:
        raise SystemExit('method anchor missing')
    s = s.replace(method_anchor, method + method_anchor, 1)
else:
    # Repair first callback closure if present.
    broken = "\t\t\t\tupdateGrid();\n\t\t\t});\n\t}\n\t#end\n\n\tfunction updateZoom() {"
    fixed = "\t\t\t\tupdateGrid();\n\t\t\t}));\n\t}\n\t#end\n\n\tfunction updateZoom() {"
    if broken in s:
        s = s.replace(broken, fixed, 1)

    if 'function openMobileChartCharacters():Void' not in s:
        old_end = "\t\t\t}));\n\t}\n\t#end\n\n\tfunction updateZoom() {"
        new_end = "\t\t\t}));\n\t}\n\n\tfunction openMobileChartCharacters():Void\n\t{\n\t\topenSubState(new MobileChartCharactersSubState(_song.player1, _song.player2, _song.player3,\n\t\t\tfunction(player:String, opponent:String, girlfriend:String)\n\t\t\t{\n\t\t\t\t_song.player1 = player;\n\t\t\t\t_song.player2 = opponent;\n\t\t\t\t_song.player3 = girlfriend;\n\t\t\t\tupdateHeads();\n\t\t\t}));\n\t}\n\t#end\n\n\tfunction updateZoom() {"
        if old_end not in s:
            raise SystemExit('chart character method anchor missing')
        s = s.replace(old_end, new_end, 1)

p.write_text(s)
