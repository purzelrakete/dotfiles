#!/usr/bin/env python

import keyring

local = {
  'all':       '[Gmail]/All Mail',
  'drafts':    '[Gmail]/Drafts',
  'important': '[Gmail]/Important',
  'sent':      '[Gmail]/Sent Mail',
  'spam':      '[Gmail]/Spam',
  'starred':   '[Gmail]/Starred',
  'trash':     '[Gmail]/Trash'
}

remote = { v:k for k, v in local.items() }
filters = [local[key] for key in ['important', 'spam', 'trash']]

def filter_remote_gmail(folder):
  return folder not in filters

def keychain(service, account):
  return keyring.get_password(service, account)

def trans_local_gmail(folder):
  return local.get(folder, folder)

def trans_remote_gmail(folder):
  return remote.get(folder, folder)

