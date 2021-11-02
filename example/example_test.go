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
