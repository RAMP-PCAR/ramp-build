import re, sys

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(1)
    r = re.compile(ur'^\W*\"version\"[:\W]*\"(\d+\.\d+\.\d+(?:-\d+)?)\"', re.MULTILINE)
    with open(sys.argv[1]) as f:
        s = f.read()
        m = re.search(r, s)
        if m is None:
            sys.exit(1)
        parts = m.group(1).split('-')
        major,minor,patch = [int(x) for x in parts[0].split('.')]
        if len(parts) == 2:
            prerelease = int(parts[1])
            print '{0}.{1}.{2}-{3}'.format(major,minor,patch,prerelease+1)
        else:
            print '{0}.{1}.{2}-{3}'.format(major,minor+1,0,1)
