import requests, shutil, zipfile, os, sys
from StringIO import StringIO

paths = {
            'core': { 'repo':'ramp-pcar-dist', 'ref':'ramp-pcar' },
            'canada': { 'repo':'ramp-pcar-dist', 'ref':'ramp-theme-canada' },
            'intranet': { 'repo':'ramp-pcar-dist', 'ref':'ramp-theme-intranet' },
            'usability': { 'repo':'ramp-pcar-dist', 'ref':'ramp-theme-usability' },
            'fgp-int': { 'repo':'ramp-pcar-dist', 'ref':'ramp-theme-fgp-int' },
        }

def fetch_theme( fname, extract_path, auth ):
    j = requests.get( url, auth=auth ).json()
    for asset in j:
        print asset.get('name','NO NAME')
        if asset.get('name','NO NAME') == fname:
            break
    else:
        print 'NOT FOUND'
        return

    dl_url = asset.get('download_url','NO URL')
    print dl_url
    a = requests.get(dl_url, auth=auth)
    if a.status_code == 200:
        data = StringIO(a.content)
        with zipfile.ZipFile(data, "r") as z:
            z.extractall( extract_path )
    else:
        print 'status:', a.status_code

if __name__ == '__main__':

    if len(sys.argv) < 2:
        print 'Usage {0} [version]'.format(sys.argv[0])
        sys.exit(1)
    ver = sys.argv[1]
    branch = 'v' + ver.rsplit('.', 1)[0]
    tok = None
    with open('.token') as f:
        tok = f.read().strip()
    print 'Fetching RAMP v{0}'.format(ver)
    tag = 'v'+ver
    auth = (tok,'x-oauth-basic')
    os.mkdir( tag )
    for theme in paths:
        paths[theme]['path'] = os.path.join( tag, theme )
        paths[theme]['ver'] = ver
        paths[theme]['tag'] = tag
        paths[theme]['branch'] = branch
        if theme == 'core':
            paths[theme]['filename'] = 'ramp-pcar-dist-{0}.zip'.format(ver)
        else:
            paths[theme]['filename'] = 'ramp-theme-{0}-dist-{1}.zip'.format(theme,ver)
        os.mkdir( paths[theme]['path'] )
    for theme in paths:
        url = 'https://api.github.com/repos/RAMP-PCAR/{repo}/contents/{tag}/{ref}?ref={branch}'.format( **paths[theme] )
        fetch_theme( paths[theme]['filename'], paths[theme]['path'], auth )

    print 'Copying to dev'
    shutil.copytree( tag, 'x:\\wwwroot\\RAMP_QC\\{0}'.format(tag) )

#   if a.status_code == 200:
#       with open(zfile, 'wb') as f:
#           for chunk in a.iter_content(1024):
#               f.write(chunk)
    
