; paths
(progn (cd "~/.emacs.d")
  (normal-top-level-add-subdirs-to-load-path))

; undo
(require 'undo-tree)

; vim - evil
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
(define-key evil-normal-state-map " #" 'calc)
(define-key evil-normal-state-map " a" 'org-agenda)
(define-key evil-normal-state-map " c" 'cfw:open-org-calendar)
(define-key evil-normal-state-map " d" 'kill-this-buffer)
(define-key evil-normal-state-map " p" 'helm-for-files)
(define-key evil-normal-state-map " q" 'save-buffers-kill-terminal)
(define-key evil-normal-state-map " s" 'save-buffer)
(define-key evil-normal-state-map " w" 'whitespace-cleanup)

; vim - dired
(defun dired-current () (interactive) (dired-at-point "."))
(define-key evil-normal-state-map " o" 'dired-current)
(evil-define-key 'normal dired-mode-map " d" 'kill-this-buffer)

; vim - error prevention
(define-key evil-normal-state-map "\M-u" 'undo)

; lisp - slime
(setq inferior-lisp-program "/usr/local/bin/sbcl")
(require 'slime)
(slime-setup)

; scala - ensime
(require 'scala-mode2)
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

; autocomplete
(setq ac-use-menu-map t)
(define-key ac-menu-map "\C-j" 'ac-next)
(define-key ac-menu-map "\C-k" 'ac-previous)

; org - globals
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

; org - focus
(evil-define-key 'normal outline-mode-map " n" 'org-narrow-to-subtree)
(evil-define-key 'normal outline-mode-map " W" 'widen)

; org - minimum for agenda
(add-hook 'org-agenda-mode-hook
  (lambda ()
    (define-key org-agenda-mode-map "\C-n" 'evil-next-buffer)
    (define-key org-agenda-mode-map "\C-p" 'evil-prev-buffer)
    (define-key org-agenda-mode-map "b" 'evil-backward-word-begin)
    (define-key org-agenda-mode-map "h" 'evil-backward-char)
    (define-key org-agenda-mode-map "j" 'evil-next-line)
    (define-key org-agenda-mode-map "k" 'evil-previous-line)
    (define-key org-agenda-mode-map "l" 'evil-forward-char)
    (define-key org-agenda-mode-map "n" 'evil-forward-word-begin)
    (define-key org-agenda-mode-map "p" 'evil-forward-word-begin)
    (define-key org-agenda-mode-map "w" 'evil-forward-word-begin)))

; org - config
(setq org-agenda-files (file-expand-wildcards "~/Dropbox/blog/org/*.org"))
(setq org-log-done t)

; helm -config
(require 'helm-files)
(setq helm-idle-delay 0.1)
(setq helm-input-idle-delay 0.1)
(setq helm-c-locate-command "mdfind %.0s %s")

; calendar
(require 'calfw)
(require 'calfw-org)
(setq calendar-week-start-day 1)

; calendar - grid
(setq cfw:fchar-junction ?╋
      cfw:fchar-vertical-line ?┃
      cfw:fchar-horizontal-line ?━
      cfw:fchar-left-junction ?┣
      cfw:fchar-right-junction ?┫
      cfw:fchar-top-junction ?┯
      cfw:fchar-top-left-corner ?┏
      cfw:fchar-top-right-corner ?┓)

; basics - numbers
(setq linum-format " %d ")
(global-linum-mode t)

; basics - theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/solarized")
(load-theme  'solarized 't)

; basics - whitespace
(setq-default show-trailing-whitespace t)
(set-face-background 'trailing-whitespace "black")

; basics - print margin
(require 'fill-column-indicator)
(setq fci-rule-column 78)
(setq fci-rule-color "black")
(fci-mode)

; basics - backups
(setq make-backup-files nil)
(setq auto-save-default nil)

; basics - unclutter
(menu-bar-mode -1)
(setq inhibit-splash-screen t)

