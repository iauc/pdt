package pdt

import (
	"encoding"
	"fmt"
)

// MaskedString protects a string value by masking it when it printed or marshalled to JSON, YAML or Text. The protected value can be revealed by calling the RevealString() method on the MaskedString value.
type MaskedString string

// MarshalText marshals the MaskedString value into a textual form, which will invariably be the value of the CensoredString constant.
func (s MaskedString) MarshalText() ([]byte, error) {
	return []byte(s.String()), nil
}

// String returns the native format for a MaskedString value, which will invariably be the CensoredString constant.
func (s MaskedString) String() string {
	return CensoredText
}

// GoString returns the Go syntax for a MaskedString value, which will invariably be the Go syntax for the CensoredString constant.
func (s MaskedString) GoString() string {
	return fmt.Sprintf("%#v", s.String())
}

// RevealString returns the underlying protected string of a MaskedString value.
func (s MaskedString) RevealString() string {
	return string(s)
}

var (
	_ encoding.TextMarshaler = (*MaskedString)(nil)
	_ fmt.Stringer           = (*MaskedString)(nil)
	_ fmt.GoStringer         = (*MaskedString)(nil)
	_ StringRevealer         = (*MaskedString)(nil)
)
