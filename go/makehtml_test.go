package main

import (
	"makehtml"
	"testing"
)

func TestNew(t *testing.T) {
	p := makehtml.New("p")
	t := p.Text()
}
