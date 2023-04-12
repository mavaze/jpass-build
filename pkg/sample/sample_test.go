package main

import (
	"testing"
)

func TestSample(t *testing.T) {
	t.Log("Sample test execution")
	if true != RunSampleFn() {
		t.Error("Expected value is not found")
	}
}
