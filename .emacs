; vim - evil
(add-to-list 'load-path "~/.emacs.d/evil/")
(setq evil-want-C-i-jump nil) ; org mode conflicts on TAB
(require 'evil)
(evil-mode 1)

; vim - remap to \C-k
(define-key evil-insert-state-map  "\C-k" 'evil-normal-state)
(define-key evil-normal-state-map  "\C-k" 'evil-force-normal-state)
(define-key evil-replace-state-map "\C-k" 'evil-normal-state)
(define-key evil-visual-state-map  "\C-k" 'evil-exit-visual-state)

; vim - buffers
(define-key evil-normal-state-map "\C-n" 'evil-next-buffer)
(define-key evil-normal-state-map "\C-p" 'evil-prev-buffer)

; vim - leaders
(define-key evil-normal-state-map " d" 'kill-buffer)
(define-key evil-normal-state-map " q" 'save-buffers-kill-terminal)
(define-key evil-normal-state-map " s" 'save-buffer)
(define-key evil-normal-state-map " a" 'org-agenda)
(define-key evil-normal-state-map " w" 'whitespace-cleanup)
(define-key evil-normal-state-map " p" 'helm-for-files)

; lisp - slime
(setq inferior-lisp-program "/usr/local/bin/sbcl")
(add-to-list 'load-path "~/.emacs.d/slime/")
(require 'slime)
(slime-setup)

; org - globals
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

; org - minimum for agenda
(add-hook 'org-agenda-mode-hook
  (lambda ()
    (define-key org-agenda-mode-map "w" 'evil-forward-word-begin)
    (define-key org-agenda-mode-map "b" 'evil-backward-word-begin)
    (define-key org-agenda-mode-map "h" 'evil-backward-char)
    (define-key org-agenda-mode-map "j" 'evil-next-line)
    (define-key org-agenda-mode-map "k" 'evil-previous-line)
    (define-key org-agenda-mode-map "l" 'evil-forward-char)))

; org - config
(setq org-agenda-files (file-expand-wildcards "~/Dropbox/blog/org/*.org"))
(setq org-log-done t)

; helm -config
(add-to-list 'load-path "~/.emacs.d/helm/")
(require 'helm-files)
(setq helm-idle-delay 0.1)
(setq helm-input-idle-delay 0.1)
(setq helm-c-locate-command "mdfind %.0s %s")

; basics - numbers
(setq linum-format " %d ")
(global-linum-mode t)

; basics - unclutter
(menu-bar-mode -1)
(setq inhibit-splash-screen t)

; basics - theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/theme")
(load-theme 'solarized-dark t)

; basics - whitespace
(setq-default show-trailing-whitespace t)
(set-face-foreground 'trailing-whitespace "black")

; basics - backups
(setq make-backup-files nil)
(setq auto-save-default nil)

