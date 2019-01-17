# python 3+
import sys, os

if sys.version_info[0] < 3:
    raise Exception("Must be using Python 3")

args = sys.argv[:]
module = args.pop(0)
action = args[0] if args else None

DATA_DIR_NAME = 'data'
HELP = '''
Download & unzip shareable links from Dropbox into the data subdirectory

Usage: %s ACTION

ACTION:
  dl    download and unzip links
  help  this help screen
''' % module


def download_all():
    try:
        import settings
    except ModuleNotFoundError:
        leave(
            'settings.py is missing. Copy settings_template.py and customise.'
        )

    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)

    if not os.path.exists(DATA_DIR_NAME):
        os.makedirs(DATA_DIR_NAME)

    for folder_name, link in settings.LINKS:
        fetch(folder_name, link)

    print('done')


def fetch(folder_name, url):
    import urllib.request

    url = url.replace('dl=0', 'dl=1')

    zip_path = os.path.join(DATA_DIR_NAME, 'tmp.zip')
    out_path = os.path.join(DATA_DIR_NAME, folder_name)

    print('Downloading %s' % folder_name)
    urllib.request.urlretrieve(url, zip_path)

    if len(out_path) > 2:
        run_command('rm -rf %s' % out_path)

    print('Unzipping %s' % zip_path)
    # -x : see https://stackoverflow.com/a/39448209/3748764
    command = 'unzip -oq %s -x / -d %s' % (
        zip_path, out_path
    )
    return run_command(command)


def run_command(command_str):
    from subprocess import call
    return call(command_str.split(' '))


def leave(message):
    print('ERROR: %s' % message)
    exit()


def help():
    print(HELP)


if action in [None, 'help']:
    help()
elif action == 'dl':
    download_all()
else:
    leave('Unknown command, please use "help" for instructions.')

