class TestVimBuffer:
    def __init__(self):
        self.name = __file__

class TestVimWindow:
    def __init__(self):
        self.cursor = [0, 0]

class TestVimCurrent:
    def __init__(self):
        self.window = TestVimWindow()
        self.buffer = TestVimBuffer()

class TestVim:
    def __init__(self):
        self.current = TestVimCurrent()

    def command(self, what):
        return None

    def eval(self, what):
        return "/tmp"
