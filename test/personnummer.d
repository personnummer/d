module tests.personnummer;

import std.exception;
import core.exception : AssertError;
import std.net.curl;
import std.stdio;
import std.json;
import std.conv;
import std.string : indexOf, replace;
import std.datetime.date : DateTime;
import std.datetime.systime : Clock;
import std.math : floor;
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

// test personnummer age
unittest
{
    foreach (i, item; testList.array())
    {
        if (item["valid"].boolean)
        {
            string pin = item["separated_long"].str;
            string year = pin[0 .. 4];
            string month = pin[4 .. 6];
            string day = pin[6 .. 8];
            if (item["type"].str == "con")
            {
                day = to!string(to!int(day) - 60);
            }

            auto t = Clock.currTime();
            const d = DateTime(to!int(year), to!int(month), to!int(day), 0, 0);
            const n = DateTime(t.year, t.month, t.day, 0, 0);
            const days = (n - d).total!"days";
            const expected = to!int(floor(days * 0.00273790926));

            foreach (j, format; availableListFormats)
            {
                if (format != "short_format" && indexOf(item["separated_format"].str, '+') == -1)
                {
                    assert(expected == Personnummer.parse(item[format].str).getAge());
                }
            }
        }
    }
}
