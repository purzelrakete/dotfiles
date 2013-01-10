; undo
(add-to-list 'load-path "~/.emacs.d/undo-tree/")
(require 'undo-tree)

; vim - evil
(add-to-list 'load-path "~/.emacs.d/evil/")
(setq evil-want-C-i-jump nil) ; org mode conflicts on TAB
(setq evil-want-C-u-scroll 't)
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
(define-key evil-normal-state-map " d" 'kill-this-buffer)
(define-key evil-normal-state-map " q" 'save-buffers-kill-terminal)
(define-key evil-normal-state-map " s" 'save-buffer)
(define-key evil-normal-state-map " a" 'org-agenda)
(define-key evil-normal-state-map " w" 'whitespace-cleanup)
(define-key evil-normal-state-map " p" 'helm-for-files)

; vim - dired
(defun dired-current () (interactive) (dired-at-point "."))
(define-key evil-normal-state-map " o" 'dired-current)
(evil-define-key 'normal dired-mode-map " d" 'kill-this-buffer)

; vim - error prevention
(define-key evil-normal-state-map "\M-u" 'undo)

; lisp - slime
(setq inferior-lisp-program "/usr/local/bin/sbcl")
(add-to-list 'load-path "~/.emacs.d/slime/")
(require 'slime)
(slime-setup)

; scala - ensime
(add-to-list 'load-path "~/.emacs.d/scala-mode")
(add-to-list 'load-path "~/.emacs.d/ensime/elisp")
(require 'scala-mode-auto)
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

; org - globals
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

; org - minimum for agenda
; TODO extract bindings into `minivim` for reuse
(add-hook 'org-agenda-mode-hook
  (lambda ()
    (define-key org-agenda-mode-map "n" 'evil-forward-word-begin)
    (define-key org-agenda-mode-map "p" 'evil-forward-word-begin)
    (define-key org-agenda-mode-map "w" 'evil-forward-word-begin)
    (define-key org-agenda-mode-map "b" 'evil-backward-word-begin)
    (define-key org-agenda-mode-map "h" 'evil-backward-char)
    (define-key org-agenda-mode-map "j" 'evil-next-line)
    (define-key org-agenda-mode-map "k" 'evil-previous-line)
    (define-key org-agenda-mode-map "\C-n" 'evil-next-buffer)
    (define-key org-agenda-mode-map "\C-p" 'evil-prev-buffer)
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

; basics - theme
(add-to-list 'load-path "~/.emacs.d/solarized")
(add-to-list 'custom-theme-load-path "~/.emacs.d/solarized")
(load-theme  'solarized 't)

; basics - whitespace
(setq-default show-trailing-whitespace t)
(set-face-background 'trailing-whitespace "black")

; basics - backups
(setq make-backup-files nil)
(setq auto-save-default nil)

; basics - unclutter
(menu-bar-mode -1)
(setq inhibit-splash-screen t)
