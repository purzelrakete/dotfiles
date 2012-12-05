; solarized
(add-to-list 'custom-theme-load-path "~/.emacs.d/solarized")
(load-theme 'solarized-dark t)

; evil
(load "~/.emacs.d/undo-tree/undo-tree.el")
(add-to-list 'load-path "~/.emacs.d/evil/")
(require 'evil)
(evil-mode 1)

; remap to \C-k
(define-key evil-insert-state-map "\C-k" 'evil-normal-state)
(define-key evil-normal-state-map "\C-k" 'evil-force-normal-state)
(define-key evil-replace-state-map "\C-k" 'evil-normal-state)
(define-key evil-visual-state-map "\C-k" 'evil-exit-visual-state)

; buffers
(define-key evil-normal-state-map "\C-n" 'evil-next-buffer)
(define-key evil-normal-state-map "\C-p" 'evil-prev-buffer)

; leader
(load "~/.emacs.d/evil-leader/evil-leader.el")
(setq evil-leader/leader "," evil-leader/in-all-states t)
(evil-leader/set-key
  "d" 'evil-destroy-buffer
  "q" 'exit
  "s" 'save-buffer)

; slime
(setq inferior-lisp-program "/usr/local/bin/sbcl")
(add-to-list 'load-path "~/.emacs.d/slime/")
(require 'slime)
(slime-setup)

; numbers
(setq linum-format " %d ")
(global-linum-mode t)

