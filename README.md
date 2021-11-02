# Protected Data Types (PDT) for Go


![branch status](https://github.com/iauc/pdt/actions/workflows/validate.yml/badge.svg?branch=main)


[![Go Report Card](https://goreportcard.com/badge/github.com/iauc/pdt)](https://goreportcard.com/report/github.com/iauc/pdt)
[![codecov](https://codecov.io/gh/iauc/pdt/branch/master/graph/badge.svg)](https://codecov.io/gh/iauc/pdt)
[![Godoc](https://img.shields.io/badge/godoc-reference-blue.svg)](https://godoc.org/github.com/iauc/pdt)
[![license](https://img.shields.io/badge/license-MIT--0-green)](./LICENSE)

This library provides Go types which makes it easy to protect sensitive data from exposure.

|Type|Protection Strategy|
|--|--|
|MaskedString|Protects the a value by masking it with a constant value whenever the string representation is requested or whenever it is marshalled.|

## Using MaskedString

The code below provides an example of how to use `MaskedString`:

```golang
package example

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/iauc/pdt"
	"github.com/stretchr/testify/assert"
)

func TestMaskedString(t *testing.T) {
	secretValue := "secretvalue"

	// pdt.MaskedString can be used to protect sensitive or secret values.
	protectedValue := pdt.MaskedString(secretValue)

	// The protected value will not appear in formatted output.
	assert.NotContains(t, fmt.Sprintf("%s", protectedValue), secretValue)

	// The protected value will not appear in marshalled output.
	m, err := json.Marshal(protectedValue)
	assert.NoError(t, err)
	assert.NotContains(t, m, secretValue)

	// The underlying secret value can be revealed.
	assert.Equal(t, fmt.Sprintf("%s", protectedValue.RevealString()), secretValue)
}

```

