module personnummer;

import std.range : sequence, stride, zip;
import std.string : indexOf, replace;
import std.conv : to;
import std.datetime.date : DateTime;
import std.datetime.systime : Clock;
import std.math : ceil, floor;

int lunh(string str)
{
	int sum = 0;

	foreach (i, s; zip(sequence!"n", str.stride(1)))
	{
		s -= '0';
		int v = s <= 9 ? s : -1;
		if (i % 2 == 0)
		{
			v *= 2;
		}

		if (v > 9)
		{
			v = v - 9;
		}

		sum += v;
	}

	return to!int(ceil(sum / 10.0)) * 10 - sum;
}

bool testDate(string year, string month, string day)
{
	const y = to!int(year);
	const m = to!int(month);
	const dd = to!int(day);
	const d = DateTime(y, m, dd);
	return d.year == y && d.month == m && d.day == dd;
}

class PersonnummerException : Exception
{
	this()
	{
		super("Invalid swedish personal identity number", __FILE__, __LINE__);
	}
}

class Personnummer
{
	string century;
	string year;
	string fullYear;
	string month;
	string day;
	string sep;
	string num;
	string check;

	this(string pin)
	{
		this._parse(pin);

		if (!this._valid())
		{
			throw new PersonnummerException();
		}
	}

	string format(bool longFormat = false)
	{
		if (longFormat)
		{
			return this.century ~ this.year ~ this.month ~ this.day ~ this.num ~ this.check;
		}

		return this.year ~ this.month ~ this.day ~ this.sep ~ this.num ~ this.check;
	}

	int getAge()
	{
		string ageDay = this.day;
		if (this.isCoordinationNumber())
		{
			ageDay = to!string(to!int(ageDay) - 60);
		}

		auto t = Clock.currTime();
		const d = DateTime(to!int(this.fullYear), to!int(this.month), to!int(ageDay), 0, 0);
		const n = DateTime(t.year, t.month, t.day, 0, 0);
		const days = (n - d).total!"days";

		return to!int(floor(days * 0.00273790926));
	}

	bool isCoordinationNumber()
	{
		try
		{
			return testDate(this.fullYear, this.month, to!string(to!int(this.day) - 60));
		}
		catch (Throwable)
		{
			return false;
		}
	}

	bool isFemale()
	{
		return !this.isMale();
	}

	bool isMale()
	{
		const sexDigit = to!int(this.num[2 .. 3]);
		return sexDigit % 2 == 1;
	}

	public static Personnummer parse(string pin)
	{
		return new Personnummer(pin);
	}

	public static bool valid(string pin)
	{
		try
		{
			new Personnummer(pin);
			return true;
		}
		catch (PersonnummerException e)
		{
			return false;
		}
	}

	private void _parse(string pin)
	{
		const plus = indexOf(pin, '+') != -1;

		pin = replace(pin, "+", "");
		pin = replace(pin, "-", "");

		if (pin.length == 12)
		{
			this.century = pin[0 .. 2];
			this.year = pin[2 .. 4];
			this.month = pin[4 .. 6];
			this.day = pin[6 .. 8];
			this.num = pin[8 .. 11];
			this.check = pin[11 .. 12];
		}
		else if (pin.length == 10)
		{
			this.year = pin[0 .. 2];
			this.month = pin[2 .. 4];
			this.day = pin[4 .. 6];
			this.num = pin[6 .. 9];
			this.check = pin[9 .. 10];
		}
		else
		{
			throw new PersonnummerException();
		}

		if (this.num == "000") {
			throw new PersonnummerException();
		}

		this.sep = "-";
		const currentTime = Clock.currTime();

		if (this.century.length == 0)
		{
			int baseYear = currentTime.year;

			if (plus)
			{
				this.sep = "+";
				baseYear -= 100;
			}

			this.century = to!string(baseYear - ((baseYear - to!int(this.year)) % 100))[0 .. 2];
		}
		else
		{
			if (currentTime.year - to!int(this.century ~ this.year) < 100)
			{
				this.sep = "-";
			}
			else
			{
				this.sep = "+";
			}
		}

		this.fullYear = this.century ~ this.year;
	}

	private bool _valid()
	{
		bool valid = lunh(this.year ~ this.month ~ this.day ~ this.num) == to!int(this.check);

		try
		{
			if (valid && testDate(this.fullYear, this.month, this.day))
			{
				return true;
			}
		}
		catch (Throwable)
		{
			return valid && this.isCoordinationNumber();
		}

		return false;
	}
}
