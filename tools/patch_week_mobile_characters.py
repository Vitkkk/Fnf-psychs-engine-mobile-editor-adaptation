from pathlib import Path

p = Path('source/editors/WeekEditorState.hx')
s = p.read_text()

import_anchor = "import mobileeditor.MobileEditorSavePaths;"
import_block = "import mobileeditor.MobileEditorSavePaths;\n#if android\nimport mobileeditor.ui.MobileButton;\nimport mobileeditor.week.MobileWeekCharactersSubState;\n#end"
if 'MobileWeekCharactersSubState' not in s:
    if import_anchor not in s:
        raise SystemExit('import anchor missing')
    s = s.replace(import_anchor, import_block, 1)

create_anchor = "\t\taddEditorBox();\n\t\treloadAllShit();"
create_block = create_anchor + "\n\n\t\t#if android\n\t\tvar mobileCharactersButton = new MobileButton(20, FlxG.height - 70, 250, 52, 'PERSONAGENS', openMobileWeekCharacters);\n\t\tmobileCharactersButton.scrollFactor.set();\n\t\tadd(mobileCharactersButton);\n\t\tvar mobileSaveButton = new MobileButton(290, FlxG.height - 70, 190, 52, 'SALVAR', function() saveWeek(weekFile));\n\t\tmobileSaveButton.scrollFactor.set();\n\t\tadd(mobileSaveButton);\n\t\t#end"
if "'PERSONAGENS', openMobileWeekCharacters" not in s:
    if create_anchor not in s:
        raise SystemExit('create anchor missing')
    s = s.replace(create_anchor, create_block, 1)

method_anchor = "\n\tvar UI_box:FlxUITabMenu;"
method = '''

\t#if android
\tfunction openMobileWeekCharacters():Void
\t{
\t\topenSubState(new MobileWeekCharactersSubState(weekFile, function()
\t\t{
\t\t\treloadAllShit();
\t\t}));
\t}
\t#end
'''
if 'function openMobileWeekCharacters():Void' not in s:
    if method_anchor not in s:
        raise SystemExit('method anchor missing')
    s = s.replace(method_anchor, method + method_anchor, 1)

p.write_text(s)
