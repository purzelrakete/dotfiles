import os
import json
from ensime_shared.errors import Error
from ensime_shared.config import commands


class TypecheckHandler(object):
    def __init__(self):
        self.currently_buffering_typechecks = False
        self.buffered_notes = {}
        super(TypecheckHandler, self).__init__()

    def buffer_typechecks(self, call_id, payload):
        """Adds typecheck events to the buffer"""
        if self.currently_buffering_typechecks:
            for note in payload['notes']:
                self.buffered_notes['notes'].append(note)

    def start_typechecking(self):
        self.log("getting ready")
        self.currently_buffering_typechecks = True
        if self.currently_buffering_typechecks:
            self.buffered_notes = {
                'notes': []
            }

    def handle_typecheck_complete(self, call_id, payload):
        """Passes the buffer to relevant display function & clears the flag+buffer"""
        if self.currently_buffering_typechecks:
            if self.vim_eval('syntastic_available'):
                self.__handle_new_scala_notes_event_with_syntastic(None, self.buffered_notes)
            else:
                self.__handle_new_scala_notes_event(None, self.buffered_notes)

            self.currently_buffering_typechecks = False
            self.buffered_notes = {}
            self.vim.command(commands["redraw"])

    def __handle_new_scala_notes_event_with_syntastic(self, call_id, payload):
        """Syntastic specific handler for response `NewScalaNotesEvent`."""

        def is_note_correct(note):
            return note['beg'] != -1 and note['end'] != -1

        current_file = os.path.abspath(self.path())
        loclist = list({
                'bufnr': self.vim.current.buffer.number,
                'lnum': note['line'],
                'col': note['col'],
                'text': note['msg'],
                'len': note['end'] - note['beg'] + 1,
                'type': note['severity']['typehint'][4:5],
                'valid': 1
            } for note in payload["notes"]
                    if current_file == os.path.abspath(note['file']) and
                    is_note_correct(note)
        )

        json_list = json.dumps(loclist)
        if json_list:
            self.vim.command(commands['syntastic_append_notes'].format(json_list))
            self.vim_command('syntastic_show_notes')

    def __handle_new_scala_notes_event(self, call_id, payload):
        """Handler for response `NewScalaNotesEvent`."""
        current_file = os.path.abspath(self.path())
        for note in payload["notes"]:
            l = note["line"]
            c = note["col"] - 1
            e = note["col"] + (note["end"] - note["beg"] + 1)

            if current_file == os.path.abspath(note["file"]):
                self.errors.append(Error(note["file"], note["msg"], l, c, e))
                matcher = commands["enerror_matcher"].format(l, c, e)
                match = self.vim.eval(matcher)
                add_match_msg = "adding match {} at line {} column {} error {}"
                self.log(add_match_msg.format(match, l, c, e))
                self.matches.append(match)
