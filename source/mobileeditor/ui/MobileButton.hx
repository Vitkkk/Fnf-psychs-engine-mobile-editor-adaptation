package mobileeditor.ui;

import flixel.ui.FlxButton;
import flixel.util.FlxColor;

/**
 * Shared large touch target used by the mobile-first editors.
 * Keeps sizing/typography consistent without changing gameplay UI classes.
 */
class MobileButton extends FlxButton
{
    public static inline var DEFAULT_HEIGHT:Int = 54;

    public function new(x:Float, y:Float, width:Float, ?height:Float = DEFAULT_HEIGHT, labelText:String = '', ?callback:Void->Void)
    {
        super(x, y, labelText, callback);
        setGraphicSize(Std.int(width), Std.int(height));
        updateHitbox();
        label.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, CENTER);
    }
}
