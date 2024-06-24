package makehtml

type MakeHTML interface {
	Text() string
	Push()
}

type HTMLObj struct {
	tag string
}

func MakePage() (html, body MakeHTML) {

}

func New(tag string, options map[string]string) (h HTMLObj) {
	h.tag = tag
	return h
}

func (h HTMLObj) Text() (t string) {
	t += "<" + h.tag + ">"
	t += "</" + h.tag + ">"
	return t
}
func (h *HTMLObj) Push(tag string) (c *HTMLObj) {

}
