module tests.personnummer;

import std.exception;
import core.exception : AssertError;
import std.net.curl;
import std.stdio;
import std.json;
import std.conv;
import std.string : indexOf, replace;
import personnummer;

string[] availableListFormats = [
    "long_format", "short_format", "separated_format", "separated_long"
];

JSONValue _testList;
JSONValue testList()
{
    if (_testList.toString() == "null")
    {
        auto content = get(
                "https://raw.githubusercontent.com/personnummer/meta/master/testdata/list.json");
        _testList = parseJSON(content);
    }
    return _testList;
}

// test personnummer list
unittest
{
    foreach (i, item; testList.array())
    {
        foreach (j, format; availableListFormats)
        {
            assert(item["valid"].boolean == Personnummer.valid(item[format].str));
        }
    }
}

// test personnummer format
unittest
{
    foreach (i, item; testList.array())
    {
        if (item["valid"].boolean)
        {
            foreach (j, format; availableListFormats)
            {
                if (format != "short_format" && indexOf(item["separated_format"].str, '+') == -1)
                {
                    assert(item["separated_format"].str == Personnummer.parse(item[format].str)
                            .format());
                    assert(item["long_format"].str == Personnummer.parse(item[format].str)
                            .format(true));
                }
            }
        }
    }
}

// test personnummer exceptions
unittest
{
    foreach (i, item; testList.array())
    {
        if (!item["valid"].boolean)
        {
            foreach (j, format; availableListFormats)
            {
                assertThrown!PersonnummerException(Personnummer.parse(item[format].str));
            }
        }
    }
}

// test personnummer sex
unittest
{
    foreach (i, item; testList.array())
    {
        if (item["valid"].boolean)
        {
            foreach (j, format; availableListFormats)
            {
                assert(item["isMale"].boolean == Personnummer.parse(item[format].str).isMale());
                assert(item["isFemale"].boolean == Personnummer.parse(item[format].str).isFemale());
            }
        }
    }
}
