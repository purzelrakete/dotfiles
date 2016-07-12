from setuptools import setup

setup(
    name='ensime_launcher',
    version='0.3',
    description=(
        'Tools for launching ensime from the CLI, compatible with vim and '
        'neovim'),
    url='http://github.com/ensime/ensime-vim',
    author="Ensime",
    license='MIT',
    packages=['ensime_launcher'],
    zip_safe=False)
