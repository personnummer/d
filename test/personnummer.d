module tests.personnummer;

import personnummer;
import std.net.curl;
import std.stdio;
import std.json;
import std.conv;

string[] availableListFormats = [
    "long_format",
    "short_format",
    "separated_format",
    "separated_long"
];

JSONValue _testList;
JSONValue testList()
{
    if (_testList.toString() == "null") {
        auto content = get("https://raw.githubusercontent.com/personnummer/meta/master/testdata/list.json");
        _testList = parseJSON(content);
    }
    return _testList;
}


//auto content = get("https://raw.githubusercontent.com/personnummer/meta/master/testdata/list.json");
//JSONValue j = parseJSON(content);
//writeln(j[0]["short_format"]);

unittest {
    foreach (i, item; testList.array()) {
        foreach (j, format; availableListFormats) {
            assert(item["valid"].boolean == Personnummer.valid(item[format].get!string));
        }
    }
}