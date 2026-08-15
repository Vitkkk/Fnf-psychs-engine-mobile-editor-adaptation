package mobileeditor.events;

typedef MobileEventParameter = {
    var id:String;
    var label:String;
    var kind:String;
    @:optional var defaultValue:String;
    @:optional var options:Array<String>;
}

typedef MobileEventValues = {
    var value1:String;
    var value2:String;
}

class MobileEventDefinition
{
    public var name:String;
    public var category:String;
    public var description:String;
    public var parameters:Array<MobileEventParameter>;
    public var encode:Map<String, String>->MobileEventValues;
    public var decode:String->String->Map<String, String>;

    public function new(name:String, category:String, description:String, parameters:Array<MobileEventParameter>,
        encode:Map<String, String>->MobileEventValues, decode:String->String->Map<String, String>)
    {
        this.name = name;
        this.category = category;
        this.description = description;
        this.parameters = parameters;
        this.encode = encode;
        this.decode = decode;
    }
}
