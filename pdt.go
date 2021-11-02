package pdt

// StringRevealer is an interface that provides a method for revealing protected values.
type StringRevealer interface {
	RevealString() string
}

// CensoredText is the text displayed instead of protected values when they are masked.
const CensoredText = "###CENSORED###"
