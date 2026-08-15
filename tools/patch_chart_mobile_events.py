from pathlib import Path
import re

p = Path('source/editors/ChartingState.hx')
s = p.read_text()

old = "import mobileeditor.MobileSafeWriter;\nimport mobileeditor.MobileEditorSavePaths;"
new = "import mobileeditor.MobileSafeWriter;\nimport mobileeditor.MobileEditorSavePaths;\n#if android\nimport mobileeditor.events.MobileEventEditorSubState;\nimport mobileeditor.ui.MobileButton;\n#end"
if 'MobileEventEditorSubState' not in s:
    if old not in s:
        raise SystemExit('import anchor missing')
    s = s.replace(old, new, 1)

if "'+ EVENTO', openMobileEventEditor" not in s:
    match = re.search(r'(?m)^[ \t]*this\.add\(_pad\);[ \t]*$', s)
    if match is None:
        raise SystemExit('create anchor missing')
    insert = "\n\n\t\t#if android\n\t\tvar mobileEventButton = new MobileButton(FlxG.width - 310, FlxG.height - 72, 280, 52, '+ EVENTO', openMobileEventEditor);\n\t\tmobileEventButton.scrollFactor.set();\n\t\tadd(mobileEventButton);\n\t\t#end"
    s = s[:match.end()] + insert + s[match.end():]

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
\t#end
'''
if 'function openMobileEventEditor():Void' not in s:
    if method_anchor not in s:
        raise SystemExit('method anchor missing')
    s = s.replace(method_anchor, method + method_anchor, 1)

# Repair the first integration revision, which closed only the constructor call.
broken = "\t\t\t\tupdateGrid();\n\t\t\t});\n\t}\n\t#end\n\n\tfunction updateZoom() {"
fixed = "\t\t\t\tupdateGrid();\n\t\t\t}));\n\t}\n\t#end\n\n\tfunction updateZoom() {"
if broken in s:
    s = s.replace(broken, fixed, 1)

p.write_text(s)
