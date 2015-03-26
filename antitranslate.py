import json, sys, csv
reload(sys)
sys.setdefaultencoding("utf-8")

PREFIX='[fr]'

# sample usage python translate.py ../ramp/src/locales/fr-CA/translation.json translation.csv [fr]

def traverse( d, prefix=[] ):
    r = []
    for k,v in d.items():
        if isinstance(v, dict):
            r.extend( traverse(v, prefix + [k]) )
        else:
            r.append( ('.'.join(prefix + [k]), v) )
    return r


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print 'Usage {0} [source as translation json] [target as translation csv] <optional prefix>'
        sys.exit(1)
    if len(sys.argv) == 4:
        PREFIX=sys.argv[3].lower()
    CLIP = len(PREFIX)

    with open(sys.argv[1],'rb') as jsonfile:
        trans = json.load(jsonfile)
    paths = traverse(trans)

    with open(sys.argv[2],'wb') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['path','reference','translation'])
        for p in paths:
            if (p[1].lower().startswith(PREFIX)):
                writer.writerow( [ p[0], p[1][CLIP:].strip(), '' ] )
