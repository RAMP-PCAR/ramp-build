import re, sys

def match_version(s):
    r = re.compile(ur'^(\d+\.\d+\.\d+(?:-\d+)?)', re.MULTILINE)
    return re.search(r, sys.argv[1])

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(1)
    m = match_version( sys.argv[1] )
    if m is None:
        sys.exit(1)
    parts = m.group(1).split('-')
    major,minor,patch = [int(x) for x in parts[0].split('.')]
    print 'MAJOR={0}'.format(major)
    print 'MINOR={0}'.format(minor)
    print 'PATCH={0}'.format(patch)
    if len(parts) == 2:
        prerelease = int(parts[1])
        print 'PRERELEASE={0}'.format(prerelease)
