from pathlib import Path

p = Path('source/editors/WeekEditorState.hx')
s = p.read_text()

import_anchor = "import mobileeditor.MobileEditorSavePaths;"
import_block = "import mobileeditor.MobileEditorSavePaths;\n#if android\nimport mobileeditor.ui.MobileButton;\nimport mobileeditor.week.MobileWeekCharactersSubState;\nimport mobileeditor.week.MobileWeekSongsSubState;\n#end"
if 'MobileWeekCharactersSubState' not in s:
    if import_anchor not in s:
        raise SystemExit('import anchor missing')
    s = s.replace(import_anchor, import_block, 1)
elif 'import mobileeditor.week.MobileWeekSongsSubState;' not in s:
    s = s.replace('import mobileeditor.week.MobileWeekCharactersSubState;',
                  'import mobileeditor.week.MobileWeekCharactersSubState;\nimport mobileeditor.week.MobileWeekSongsSubState;', 1)

create_anchor = "\t\taddEditorBox();\n\t\treloadAllShit();"
create_block = create_anchor + "\n\n\t\t#if android\n\t\tvar mobileCharactersButton = new MobileButton(20, FlxG.height - 70, 230, 52, 'PERSONAGENS', openMobileWeekCharacters);\n\t\tmobileCharactersButton.scrollFactor.set();\n\t\tadd(mobileCharactersButton);\n\t\tvar mobileSongsButton = new MobileButton(270, FlxG.height - 70, 220, 52, 'MUSICAS', openMobileWeekSongs);\n\t\tmobileSongsButton.scrollFactor.set();\n\t\tadd(mobileSongsButton);\n\t\tvar mobileSaveButton = new MobileButton(510, FlxG.height - 70, 190, 52, 'SALVAR', function() saveWeek(weekFile));\n\t\tmobileSaveButton.scrollFactor.set();\n\t\tadd(mobileSaveButton);\n\t\t#end"
if "'PERSONAGENS', openMobileWeekCharacters" not in s:
    if create_anchor not in s:
        raise SystemExit('create anchor missing')
    s = s.replace(create_anchor, create_block, 1)
else:
    old_buttons = "\t\tvar mobileCharactersButton = new MobileButton(20, FlxG.height - 70, 250, 52, 'PERSONAGENS', openMobileWeekCharacters);\n\t\tmobileCharactersButton.scrollFactor.set();\n\t\tadd(mobileCharactersButton);\n\t\tvar mobileSaveButton = new MobileButton(290, FlxG.height - 70, 190, 52, 'SALVAR', function() saveWeek(weekFile));\n\t\tmobileSaveButton.scrollFactor.set();\n\t\tadd(mobileSaveButton);"
    new_buttons = "\t\tvar mobileCharactersButton = new MobileButton(20, FlxG.height - 70, 230, 52, 'PERSONAGENS', openMobileWeekCharacters);\n\t\tmobileCharactersButton.scrollFactor.set();\n\t\tadd(mobileCharactersButton);\n\t\tvar mobileSongsButton = new MobileButton(270, FlxG.height - 70, 220, 52, 'MUSICAS', openMobileWeekSongs);\n\t\tmobileSongsButton.scrollFactor.set();\n\t\tadd(mobileSongsButton);\n\t\tvar mobileSaveButton = new MobileButton(510, FlxG.height - 70, 190, 52, 'SALVAR', function() saveWeek(weekFile));\n\t\tmobileSaveButton.scrollFactor.set();\n\t\tadd(mobileSaveButton);"
    if old_buttons in s:
        s = s.replace(old_buttons, new_buttons, 1)

method_anchor = "\n\tvar UI_box:FlxUITabMenu;"
methods = '''

\t#if android
\tfunction openMobileWeekCharacters():Void
\t{
\t\topenSubState(new MobileWeekCharactersSubState(weekFile, function()
\t\t{
\t\t\treloadAllShit();
\t\t}));
\t}

\tfunction openMobileWeekSongs():Void
\t{
\t\topenSubState(new MobileWeekSongsSubState(weekFile, function()
\t\t{
\t\t\treloadAllShit();
\t\t}));
\t}
\t#end
'''
if 'function openMobileWeekCharacters():Void' not in s:
    if method_anchor not in s:
        raise SystemExit('method anchor missing')
    s = s.replace(method_anchor, methods + method_anchor, 1)
elif 'function openMobileWeekSongs():Void' not in s:
    old_end = "\t\t}));\n\t}\n\t#end\n\n\tvar UI_box:FlxUITabMenu;"
    new_end = "\t\t}));\n\t}\n\n\tfunction openMobileWeekSongs():Void\n\t{\n\t\topenSubState(new MobileWeekSongsSubState(weekFile, function()\n\t\t{\n\t\t\treloadAllShit();\n\t\t}));\n\t}\n\t#end\n\n\tvar UI_box:FlxUITabMenu;"
    if old_end not in s:
        raise SystemExit('method extension anchor missing')
    s = s.replace(old_end, new_end, 1)

p.write_text(s)
