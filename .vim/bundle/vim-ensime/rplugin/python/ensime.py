import sys
import os
import inspect

def ensime_init_path():
    path = os.path.abspath(inspect.getfile(inspect.currentframe()))
    if path.endswith('/rplugin/python/ensime.py'): # nvim rplugin
        sys.path.append(os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(path)))))
    elif path.endswith('/autoload/ensime.vim.py'): # vim plugin
        sys.path.append(os.path.join(
            os.path.dirname(os.path.dirname(path))))

ensime_init_path()

from ensime_shared.ensime import Ensime
import neovim

# Params for autocmd by default
autocmd_params = {
    "pattern": "*.scala",
    "eval": 'expand("<afile>")',
    "sync": True
}

# Params for command by default
command_params = {
    "range": "",
    "nargs": "*",
    "sync": True
}

@neovim.plugin
class NeovimEnsime(Ensime):
    """Decorate as a Neovim plugin with the Ensime functionality."""
    def __init__(self, vim):
        super(NeovimEnsime, self).__init__(vim)

    @neovim.command('EnToggleTeardown', **command_params)
    def com_en_toggle_teardown(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_toggle_teardown(*args, **kwargs)

    @neovim.command('EnTypeCheck', **command_params)
    def com_en_type_check(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_type_check(*args, **kwargs)

    @neovim.command('EnType', **command_params)
    def com_en_type(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_type(*args, **kwargs)

    @neovim.command('EnSearch', **command_params)
    def com_en_sym_search(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_sym_search(*args, **kwargs)

    @neovim.command('EnToggleFullType', **command_params)
    def com_en_toggle_fulltype(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_toggle_fulltype(*args, **kwargs)

    @neovim.command('EnFormatSource', **command_params)
    def com_en_format_source(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_format_source(*args, **kwargs)

    @neovim.command('EnDeclaration', **command_params)
    def com_en_declaration(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_declaration(*args, **kwargs)

    @neovim.command('EnDeclarationSplit', **command_params)
    def com_en_declaration_split(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_declaration_split(*args, **kwargs)

    @neovim.command('EnSymbolByName', **command_params)
    def com_en_symbol_by_name(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_symbol_by_name(*args, **kwargs)

    @neovim.command('EnSymbol', **command_params)
    def com_en_symbol(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_symbol(*args, **kwargs)

    @neovim.command('EnInspectType', **command_params)
    def com_en_inspect_type(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_inspect_type(*args, **kwargs)

    @neovim.command('EnDocUri', **command_params)
    def com_en_doc_uri(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_doc_uri(*args, **kwargs)

    @neovim.command('EnDocBrowse', **command_params)
    def com_en_doc_browse(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_doc_browse(*args, **kwargs)

    @neovim.command('EnSuggestImport', **command_params)
    def com_en_suggest_import(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_suggest_import(*args, **kwargs)

    @neovim.command('EnDebugSetBreak', **command_params)
    def com_en_debug_set_break(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_debug_set_break(*args, **kwargs)

    @neovim.command('EnDebugClearBreaks', **command_params)
    def com_en_debug_clear_breaks(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_debug_clear_breaks(*args, **kwargs)

    @neovim.command('EnDebugStart', **command_params)
    def com_en_debug_start(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_debug_start(*args, **kwargs)

    @neovim.command('EnInstall', **command_params)
    def com_en_install(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_install(*args, **kwargs)

    @neovim.command('EnShowPackage', **command_params)
    def com_en_package_inspect(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_package_inspect(*args, **kwargs)

    @neovim.command('EnDebugContinue', **command_params)
    def com_en_debug_continue(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_debug_continue(*args, **kwargs)

    @neovim.command('EnDebugBacktrace', **command_params)
    def com_en_debug_backtrace(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_debug_backtrace(*args, **kwargs)

    @neovim.command('EnRename', **command_params)
    def com_en_rename(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_rename(*args, **kwargs)

    @neovim.function('EnPackageDecl', sync=True)
    def fun_en_package_decl(self, *args, **kwargs):
        super(NeovimEnsime, self).fun_en_package_decl(*args, **kwargs)

    @neovim.command('EnInline', **command_params)
    def com_en_inline(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_inline(*args, **kwargs)

    @neovim.command('EnOrganizeImports', **command_params)
    def com_en_organize_imports(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_organize_imports(*args, **kwargs)

    @neovim.command('EnAddImport', **command_params)
    def com_en_add_import(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_add_import(*args, **kwargs)

    @neovim.command('EnClients', range='', nargs='0', sync=True)
    def com_en_clients(self, *args, **kwargs):
        super(NeovimEnsime, self).com_en_clients(*args, **kwargs)

    @neovim.autocmd('VimEnter', **autocmd_params)
    def au_vim_enter(self, *args, **kwargs):
        super(NeovimEnsime, self).au_vim_enter(*args, **kwargs)

    @neovim.autocmd('VimLeave', **autocmd_params)
    def au_vim_leave(self, *args, **kwargs):
        super(NeovimEnsime, self).au_vim_leave(*args, **kwargs)

    @neovim.autocmd('BufLeave', **autocmd_params)
    def au_buf_leave(self, *args, **kwargs):
        super(NeovimEnsime, self).au_buf_leave(*args, **kwargs)

    @neovim.autocmd('CursorHold', **autocmd_params)
    def au_cursor_hold(self, *args, **kwargs):
        super(NeovimEnsime, self).au_cursor_hold(*args, **kwargs)

    @neovim.autocmd('CursorMoved', **autocmd_params)
    def au_cursor_moved(self, *args, **kwargs):
        super(NeovimEnsime, self).au_cursor_moved(*args, **kwargs)

    @neovim.function('EnCompleteFunc', sync=True)
    def fun_en_complete_func(self, *args, **kwargs):
        return super(NeovimEnsime, self).fun_en_complete_func(*args, **kwargs)
