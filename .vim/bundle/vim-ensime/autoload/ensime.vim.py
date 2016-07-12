import sys
import os
import inspect


def ensime_init_path():
    path = os.path.abspath(inspect.getfile(inspect.currentframe()))
    if path.endswith('/rplugin/python/ensime.py'):  # nvim rplugin
        sys.path.append(os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(path)))))
    elif path.endswith('/autoload/ensime.vim.py'):  # vim plugin
        sys.path.append(os.path.join(
            os.path.dirname(os.path.dirname(path))))

ensime_init_path()

import vim

from ensime_shared.ensime import Ensime
ensime_plugin = Ensime(vim)
