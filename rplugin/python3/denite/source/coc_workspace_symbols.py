import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent.parent.resolve()))

from coc_workspace_symbols.symbol_base import SymbolBase


class Source(SymbolBase):
    def __init__(self, vim):
        super().__init__(vim, 'coc-workspace-symbols')

    def start_lookup(self, query):
        self.vim.call('denite_coc_workspace_symbols#workspace_symbols', query)
