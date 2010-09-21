import sys
import xml.sax
from xml.dom.pulldom import SAX2DOM
from xml.sax.handler import ContentHandler


def get_text(root):
    rc = []
    for node in root.childNodes:
        if node.nodeType == node.TEXT_NODE:
            rc.append(node.data)
    return ''.join(rc)


class DiscogsReleaseXmlHandler(SAX2DOM):

    def __init__(self, discogs_ids):
        SAX2DOM.__init__(self)
        self._discogs_ids = discogs_ids

    def restart(self):
        self.endElement('releases')
        self.endDocument()
        self.clear()
        self.elementStack[:] = []
        self.firstEvent = [None, None]
        self.pending_events = []
        self.push(self.document)
        self.startDocument()
        self.startElement('releases', {})

    def endElement(self, name):
        SAX2DOM.endElement(self, name)
        if name == 'release':
            release = self.document.getElementsByTagName('release')[0]
            self.restart()
            #print release.toprettyxml('    ').encode('utf8')
            id = int(release.getAttribute('id'))
            sys.stderr.write('%d\r' % id)
            if id not in self._discogs_ids:
                return
            catnos = []
            labels = []
            for node in release.getElementsByTagName('label'):
                catnos.append(node.getAttribute('catno'))
                labels.append(node.getAttribute('name'))
            nodes = release.getElementsByTagName('country')
            country = get_text(nodes[0]) if nodes else ''
            nodes = release.getElementsByTagName('released')
            date = get_text(nodes[0]) if nodes else ''
            formats = []
            for node in release.getElementsByTagName('format'):
                formats.append(node.getAttribute('name'))
            line = '%s\t%s\t%s\t%s\t%s\t%s' % (id, ';'.join(catnos), ';'.join(labels), country, date, ';'.join(set(formats)))
            print line.encode('utf-8')


discogs_ids = set()
for line in open(sys.argv[1]):
    try:
        discogs_ids.add(int(line.strip()))
    except ValueError:
        pass

xml.sax.parse(sys.stdin, DiscogsReleaseXmlHandler(discogs_ids))

