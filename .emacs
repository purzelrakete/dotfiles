; vim - evil
(load "~/.emacs.d/undo-tree/undo-tree.el")
(add-to-list 'load-path "~/.emacs.d/evil/")
(setq evil-want-C-i-jump nil) ; org mode conflict on TAB
(require 'evil)
(evil-mode 1)

; vim - remap to \C-k
(define-key evil-insert-state-map "\C-k" 'evil-normal-state)
(define-key evil-normal-state-map "\C-k" 'evil-force-normal-state)
(define-key evil-replace-state-map "\C-k" 'evil-normal-state)
(define-key evil-visual-state-map "\C-k" 'evil-exit-visual-state)

; vim - buffers
(define-key evil-normal-state-map "\C-n" 'evil-next-buffer)
(define-key evil-normal-state-map "\C-p" 'evil-prev-buffer)

; vim - leader
(load "~/.emacs.d/evil-leader/evil-leader.el")
(setq evil-leader/leader "," evil-leader/in-all-states t)
(evil-leader/set-key
  "d" 'evil-destroy-buffer
  "q" 'exit
  "s" 'save-buffer)

; lisp - slime
(setq inferior-lisp-program "/usr/local/bin/sbcl")
(add-to-list 'load-path "~/.emacs.d/slime/")
(require 'slime)
(slime-setup)

; org - deft
(add-to-list 'load-path "~/.emacs.d/deft/")
(require 'deft)
(setq deft-directory "~/Dropbox/blog")
(setq deft-extension "org")
(setq deft-text-mode 'org-mode)

; org - bindings
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

; org - startup
(setq org-startup-indented 't)
(switch-to-buffer (get-buffer-create (generate-new-buffer-name "*org*")))
(org-mode)

; basics - numbers
(setq linum-format " %d ")
(global-linum-mode t)

; basics - unclutter
(menu-bar-mode -1)
(setq inhibit-splash-screen t)

; basics - theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/theme")
(load-theme 'solarized-dark t)

