# personnummer [![Build Status](https://github.com/personnummer/d/workflows/test/badge.svg)](https://github.com/personnummer/d/actions)

Validate Swedish personal identity numbers. Follows version 3 of the [specification](https://github.com/personnummer/meta#package-specification-v3).

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

## License

MIT