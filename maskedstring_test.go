package pdt

import (
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"gopkg.in/yaml.v2"
)

func TestMaskedString(t *testing.T) {

	clearValue := "asd12435"
	t.Logf("clearValue = %s", clearValue)

	cmj, err := json.Marshal(map[string]string{
		"SensitiveValue": clearValue,
	})
	assert.NoError(t, err)
	t.Logf("m = %s", cmj)

	type container struct {
		SensitiveValue MaskedString `yaml:"SensitiveValue"`
	}
	var pc *container

	pc = &container{}
	assert.Equal(t, "", pc.SensitiveValue.RevealString())
	err = json.Unmarshal(cmj, pc)
	assert.NoError(t, err)
	t.Logf("pc = %#v", pc)
	assert.Equal(t, clearValue, pc.SensitiveValue.RevealString())

	pc = &container{}
	assert.Equal(t, "", pc.SensitiveValue.RevealString())
	err = yaml.Unmarshal(cmj, pc)
	assert.NoError(t, err)
	t.Logf("pc = %#v", pc)
	assert.Equal(t, clearValue, pc.SensitiveValue.RevealString())

	protectedValue := pc.SensitiveValue

	assert.Equal(t, CensoredText, fmt.Sprintf("%s", protectedValue))
	assert.Equal(t, CensoredText, fmt.Sprintf("%v", protectedValue))
	assert.Equal(t, fmt.Sprintf("\"%s\"", CensoredText), fmt.Sprintf("%#v", protectedValue))

	pmj, err := json.Marshal(pc)
	assert.NoError(t, err)
	t.Logf("c = %s", pmj)
	assert.Equal(t, fmt.Sprintf("{\"SensitiveValue\":\"%s\"}", CensoredText), string(pmj))

	pmy, err := yaml.Marshal(protectedValue)
	assert.NoError(t, err)
	t.Logf("c = %s", pmy)
	assert.Equal(t, CensoredText, strings.Trim(string(pmy), "\n '\""))
}
