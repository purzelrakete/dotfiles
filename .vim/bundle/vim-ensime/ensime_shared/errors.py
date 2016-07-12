import os


class InvalidJavaPathError(OSError):
    """Raised when ensime-vim cannot find a valid Java executable."""

    def __init__(self, errno, msg, filename, *args):
        super(InvalidJavaPathError, self).__init__(errno, msg, filename, *args)


class Error(object):
    """Represents an error in source code reported by ENSIME."""

    # l, c, e are line, (beginning) column and end (column)
    # TODO: docstring and rename these bad, lint-failing params :-P
    def __init__(self, path, message, l, c, e):
        self.path = os.path.abspath(path)
        self.message = message
        self.l, self.c, self.e = l, c, e

    def includes(self, path, cursor):
        return self.path == os.path.abspath(path) \
            and cursor[0] == self.l \
            and self.c <= cursor[1] \
            and cursor[1] < self.e

    def get_truncated_message(self, cursor, width):
        size = len(self.message)
        if size < width:
            return self.message
        percent = float(cursor[1] - self.c) / (self.e - self.c)
        center = int(percent * size)
        start = center - width / 2
        end = center + width / 2
        if start < 0:
            start = 0
            end = width
        elif end > size:
            end = size
            start = size - width
        return self.message[start:end]
