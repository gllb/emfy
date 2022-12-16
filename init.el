;;; Emfy 0.2.0 <https://github.com/susam/emfy>

;; Customize user interface.
(menu-bar-mode 0)
(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode 0))
(setq inhibit-startup-screen t)
(column-number-mode)
(setq visible-bell 1)

;; Show line number globally
(global-display-line-numbers-mode)

;; Interactively do things.
;; (ido-mode 1)
;; (ido-everywhere)
;; (setq ido-enable-flex-matching t)
;; (fido-mode)

;; Show stray whitespace.
(setq-default show-trailing-whitespace t)
(setq-default indicate-empty-lines t)
(setq-default indicate-buffer-boundaries 'left)

;; Consider a period followed by a single space to be end of sentence.
(setq sentence-end-double-space nil)

;; Use spaces, not tabs, for indentation.
(setq-default indent-tabs-mode nil)

;; Display the distance between two tab stops as 4 characters wide.
(setq-default tab-width 4)

;; Indentation setting for various languages.
(setq c-basic-offset 4)
(setq js-indent-level 2)
(setq css-indent-offset 2)

;; Highlight matching pairs of parentheses.
(setq show-paren-delay 0)
(show-paren-mode)

;; Write auto-saves and backups to separate directory.
(make-directory "~/.tmp/emacs/auto-save/" t)
(setq auto-save-file-name-transforms '((".*" "~/.tmp/emacs/auto-save/" t)))
(setq backup-directory-alist '(("." . "~/.tmp/emacs/backup/")))

;; Do not move the current file while creating backup.
(setq backup-by-copying t)

;; Disable lockfiles.
(setq create-lockfiles nil)

;; Workaround for https://debbugs.gnu.org/34341 in GNU Emacs <= 26.3.
(when (and (version< emacs-version "26.3") (>= libgnutls-version 30603))
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

;; Write customizations to a separate file instead of this file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

;; Enable installation of packages from MELPA.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install packages.
(dolist (package '(markdown-mode use-package rainbow-delimiters impatient-mode))
  (unless (package-installed-p package)
    (package-install package)))

;; Enable Rainbow Delimiters.
(add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
(add-hook 'ielm-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-interaction-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)

;; Customize Rainbow Delimiters.
(require 'rainbow-delimiters)
(set-face-foreground 'rainbow-delimiters-depth-1-face "#c66")  ; red
(set-face-foreground 'rainbow-delimiters-depth-2-face "#6c6")  ; green
(set-face-foreground 'rainbow-delimiters-depth-3-face "#69f")  ; blue
(set-face-foreground 'rainbow-delimiters-depth-4-face "#cc6")  ; yellow
(set-face-foreground 'rainbow-delimiters-depth-5-face "#6cc")  ; cyan
(set-face-foreground 'rainbow-delimiters-depth-6-face "#c6c")  ; magenta
(set-face-foreground 'rainbow-delimiters-depth-7-face "#ccc")  ; light gray
(set-face-foreground 'rainbow-delimiters-depth-8-face "#999")  ; medium gray
(set-face-foreground 'rainbow-delimiters-depth-9-face "#666")  ; dark gray

;; Custom command.
(defun show-current-time ()
  "Show current time."
  (interactive)
  (message (current-time-string)))

;; Custom key sequences.
(global-set-key (kbd "C-c t") 'show-current-time)
(global-set-key (kbd "C-c d") 'delete-trailing-whitespace)
(global-set-key (kbd "C-c o") 'browse-url-at-point)

;; Start server.
(require 'server)
(unless (server-running-p)
  (server-start))

;; Enable Electric-pair mode.
(electric-pair-mode)

;; Impatient filter for markdown preview
(defun markdown-filter (buffer)
  (princ
   (with-temp-buffer
     (let ((tmpname (buffer-name)))
       (set-buffer buffer)
       (set-buffer (markdown tmpname)) ; the function markdown is in `markdown-mode.el'
       (buffer-string)))
   (current-buffer)))

;; Load keychain configuration
(keychain-refresh-environment)

;; Enable ffap-binding (find-file-at-point) C-u C-x C-f
(ffap-bindings)
(setq ffap-require-prefix t)

(require 'use-package)

(use-package solarized-theme
  :ensure t
  :config (load-theme 'solarized-light t))

(use-package magit
  :ensure t
  :config
  (setq magit-repository-directories
      `(("~/vcs" . 5)))
  )

(use-package python-mode
  :ensure t)
(use-package terraform-mode
  :ensure t)

;; helm
(use-package helm
  :ensure t
  ;; :demand
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x b" . helm-buffers-list)
         ("C-x c o" . helm-occur) ;SC
         ("M-y" . helm-show-kill-ring) ;SC
         ("C-x r b" . helm-filtered-bookmarks) ;SC
         )
  ;; :preface (require 'helm-config)
  :init (helm-mode 1))

;; projectile
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p". projectile-command-map))
  :config
  (setq projectile-project-search-path '(("~/vcs" . 10)))
  (setq projectile-switch-project-action 'projectile-vc)
  )

;; LSP
(use-package lsp-mode
  :ensure t
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)

         (python-mode . lsp)
         ;; https://github.com/juliosueiras/terraform-lsp
         (terraform-mode . lsp)
         ;; if you want which-key integration

         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)
;; if you are helm user
;; (use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
;; (use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
;; (use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
;; (use-package which-key
;; :config
;; (which-key-mode))

(use-package json-mode
  :ensure t)

;;(use-package forge
;;  :ensure t
;;  :init
;;  (setq auth-sources '("~/.authinfo.gpg"))
;;  :after magit)
(put 'upcase-region 'disabled nil)
