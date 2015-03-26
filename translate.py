import json, sys, csv
reload(sys)
sys.setdefaultencoding("utf-8")

# sample usage python translate.py ../translation.csv ../ramp/src/locales/fr-CA/translation.json

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print 'Usage {0} [source as translation csv] [target as translation json]'
        sys.exit(1)

    with open(sys.argv[2],'rb') as jsonfile:
        trans = json.load(jsonfile)

    with open(sys.argv[1],'rb') as csvfile:
        reader = csv.reader(csvfile)
        reader.next()
        for row in reader:
            path = row[0].lstrip('.').split('.')
            node = trans
            for p in path[:-1]:
                node = node[p]
            node[path[-1]] = row[2]

    with open(sys.argv[2],'wb') as outfile:
        json.dump(trans,outfile,ensure_ascii=False,indent=4)
