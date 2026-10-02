# personnummer [![Build Status](https://github.com/personnummer/d/workflows/test/badge.svg)](https://github.com/personnummer/d/actions)

Validate Swedish personal identity numbers.

Install the module with dub:

```
dub add personnummer
```

## Example

```d
import personnummer;

void main() {
    Personnummer.valid("198507099805")
    // => true
}
```

## In memoriam

Fredrik "Frozzare" Forsmo (1991-2026) was the initiator, co-founder and a core contributor of the personnummer project. This library carries his work. He is missed.

## License

MIT