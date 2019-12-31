;; -*- mode: emacs-lisp -*-
;;; emacs --- Emacs configuration
;;
;;; Commentary:
;;
;; This should be placed at ~/.emacs.d/init.dl.
;;
;;
;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BEGIN CUSTOM CONFIGS BY EMACS; DO NOT MODIFY

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ace-isearch-input-length 20)
 '(ace-isearch-jump-delay 0.6)
 '(c-basic-offset 2)
 '(case-fold-search t)
 '(column-number-mode t)
 '(current-language-environment "UTF-8")
 '(default-input-method "rfc1345")
 '(fringe-mode 0 nil (fringe))
 '(global-font-lock-mode t nil (font-lock))
 '(global-whitespace-mode nil)
 '(ido-enable-flex-matching t)
 '(ido-mode (quote both) nil (ido))
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(load-home-init-file t t)
 '(make-backup-files nil)
 '(mouse-wheel-mode t nil (mwheel))
 '(mouse-wheel-progressive-speed nil)
 '(mouse-wheel-scroll-amount (quote (3 ((shift) . 1) ((control)))))
 '(package-selected-packages
   (quote
    (highlight-indent-guides popup flyckeck-popup-tip blacken flyspell-prog blacken-mode any-ini-mode professional-theme github-modern-theme magit web-mode auto-complete use-package helm-swoop ace-jump-mode epc flycheck plantuml-mode yaml-mode scala-mode neotree markdown-mode json-mode jedi flymake-cursor dockerfile-mode cython-mode ansible ace-isearch)))
 '(scroll-bar-mode t)
 '(scroll-bar-width 6 t)
 '(select-enable-clipboard t)
 '(show-paren-mode t nil (paren))
 '(size-indication-mode t)
 '(tab-always-indent t)
 '(tab-width 2)
 '(tool-bar-mode nil)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CUSTOM CONFIGS BY TS; CAN MODIFY

;;(set-face-attribute 'default nil :height 75)
;;(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
(setq frame-title-format '("" "%f"))  ;; for frame-cmds.el
(setq ring-bell-function 'ignore)  ;; Disable beeping

;; Fonts
(when window-system
  (setq monn (length (display-monitor-attributes-list)))
  (if (> (/ (display-pixel-width) monn) 2550)
      (create-fontset-from-ascii-font 
       "Hack:weight=normal:slant=normal:size=18" nil "hackandjp")
    (create-fontset-from-ascii-font 
     "Hack:weight=normal:slant=normal:size=14" nil "hackandjp"))
  (set-fontset-font "fontset-hackandjp"
		                'unicode
		                (font-spec :family "Noto Sans Mono CJK JP")
		                nil 
		                'append)
  (add-to-list 'default-frame-alist '(font . "fontset-hackandjp")))

;; BUGFIX: For fixing a startup error message
;;
;;   http.elpa.gnu.org:443*-257153" has a running process; kill it? (y or n) y
;;
;; This bug should be fixed on and after Emacs version 26.3.
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")


;; PACKAGE CONFIGURATION

(require 'package)
(add-to-list 'package-archives
             '("MELPA" . "https://melpa.org/packages/") t)
;;           '("MELPA stable" . "https://stable.melpa.org/packages/") t)
;;           '("Marmalade" . "https://marmalade-repo.org/packages/"))

;; For important compatibility libraries like cl-lib
;; (when (< emacs-major-version 24)
;;   (add-to-list 'package-archives
;;                '("gnu" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents) (package-install 'use-package))

;; Theme
(use-package professional-theme
  :ensure t
  :config
  (load-theme 'professional t))

;; Utility packages
(use-package epc
  :ensure t)

(use-package popup
  :ensure t)

(use-package url
  :ensure t)


;; UTILITY VARIABLES AND FUNCTIONS

;; Custom emacs lisp directory for .el files
(defconst my-lispdir "~/.emacs.d/lisp/")

(if (not (file-directory-p my-lispdir))
    (make-directory my-lispdir :parents))
(if (file-directory-p my-lispdir)
    (add-to-list 'load-path my-lispdir))


(defun ensure-downloaded-file (src dest)
  "Download a file from a URL and save to the disk.

  SRC is the source URL, DEST is the destination file path."
  (if (not (file-exists-p dest))
      (url-copy-file src dest)))


;; CUSTOM KEYBINDINGS

;; Activate windmove to switch to another window by M-<U|D|L|R>
(windmove-default-keybindings 'meta)
;; ... or define global shortcuts:
;; (global-set-key (kbd "C-c <left>")  'windmove-left)
;; (global-set-key (kbd "C-c <right>") 'windmove-right)
;; (global-set-key (kbd "C-c <up>")    'windmove-up)
;; (global-set-key (kbd "C-c <down>")  'windmove-down)


(defun ts/insert-line-before (times)
  "Insert a newline(s) above the line containing the cursor."
  (interactive "p") ; called from M-x
  (save-excursion ; store position
    (move-beginning-of-line 1)
    (newline times))) ; insert new line
(global-set-key (kbd "C-S-o") 'ts/insert-line-before)


;; [F5] to trigger revert-buffer without confirmation
(defun revert-buffer-no-confirm (&optional force-reverting)
  "Interactive call to 'revert-buffer'.

  Ignoring the auto-save file and not requesting for confirmation.
  When the current buffer is modified, the command refuses to
  revert it, unless you specify the optional argument: 
  FORCE-REVERTING to true."
  (interactive "P")
  (if (or force-reverting (not (buffer-modified-p)))
      (revert-buffer :ignore-auto :noconfirm)
    (error "The buffer has been modified")))
(global-set-key (kbd "<f5>") 'revert-buffer-no-confirm)


;; PACKAGES

;; Dired -- ignore some files
(require 'dired-x)
(setq-default dired-omit-files-p t)
(setq dired-omit-files "^\\.$\\|^\\.\\.$\\|\\.pyc$\\|\\.pyo$\\|\#$")


;; Based on the number of characters used for search, ace-isearch uses
;; different mode.
(use-package ace-isearch
  :ensure t
  :config
  (global-ace-isearch-mode 1))


(use-package ace-jump-mode
  :ensure t)


(use-package ansible
  :after (yaml-mode)
  :ensure t
  :init
  (defun find-vault-password-file (name)
    (setq dir (locate-dominating-file default-directory name))
    (if dir (concat dir name) "~/vault_pass"))
  (defun my-ansible-mode-hook ()
    (if (file-exists-p (locate-dominating-file
                        default-directory "ansible.cfg"))
        (progn
          (setq ansible-vault-password-file
                (find-vault-password-file "vault-password"))
          (ansible 1))))
  (add-hook 'yaml-mode-hook 'my-ansible-mode-hook)
  (add-hook 'ansible-hook 'ansible-auto-decrypt-encrypt))


(use-package any-ini-mode
  :mode ".*\\.ini$" ".*\\.conf$" ".*\\.service$"
  :init
  (ensure-downloaded-file
   "https://www.emacswiki.org/emacs/download/any-ini-mode.el"
   (concat my-lispdir "any-ini-mode.el")))


(use-package auto-complete
  :ensure t
  :config
  ;; (setq ac-show-menu-immediately-on-auto-complete t)
  (setq ac-max-width 0.35)
  (ac-config-default))


;; if using multiple virtual env, this might become useful:
;;
;;   http://stackoverflow.com/questions/21246218/how-can-i-make-emacs-jedi-use-project-specific-virtualenvs
;; (setq jedi:server-args (list (or (buffer-file-name) default-directory)))
;; (push "--sys-path" jedi:server-args)
;; (message "for jedi:server-args %s" jedi:server-args)

;; black -- The opinionated Python code formatter
;;
;; Need `pip install black` to actually use it.
;;
;; To activate blacken-mode per project basis, place
;;
;;   ((python-mode . ((eval . (blacken-mode 1)))))
;;
;; in .dir-locals.el.
(use-package blacken
  :after python
  :if (not (version< emacs-version "25.2"))
  :ensure t)


(use-package cython-mode
  :after python
  :ensure t)


(use-package dockerfile-mode
  :ensure t)


(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode))


(use-package flyckeck-popup-tip
  :after (flycheck-mode popup)
  :config
  (with-eval-after-load 'flycheck
    (add-hook 'flycheck-mode-hook 'flycheck-popup-tip-mode)))


;; Need shellcheck: apt install shellcheck
(use-package flymake-shellcheck
  :if (executable-find "shellcheck")
  :commands flymake-shellcheck-load
  :init
  (setq sh-basic-offset 2
        sh-indentation 2)
  (add-to-list 'auto-mode-alist '("/bashrc\\'" . sh-mode))
  (add-to-list 'auto-mode-alist '("/bash_.*\\'" . sh-mode))
  (add-to-list 'auto-mode-alist '("\\.bats\\'" . sh-mode))
  (add-to-list 'interpreter-mode-alist '("bats" . sh-mode))
  (add-hook 'sh-mode-hook 'flymake-shellcheck-load)
  (add-hook 'sh-mode-hook 'highlight-indent-guides-mode))


(use-package flyspell
  :hook ((text-mode) . flyspell-mode))


(use-package flyspell-prog
  :after (flyspell)
  :hook ((prog-mode) . flyspell-prog-mode))


(use-package helm-swoop
  :ensure t)


(use-package highlight-indent-guides
  :ensure t
  :hook ((python-mode web-mode emacs-lisp-mode) . highlight-indent-guides-mode)
  :config
  ;; (setq highlight-indent-guides-auto-enabled nil)
  ;; (set-face-foreground 'highlight-indent-guides-character-face "dimgray")
  (setq highlight-indent-guides-method 'character
        highlight-indent-guides-character ?\┆
        highlight-indent-guides-responsive 'top
        highlight-indent-guides-delay 0
        highlight-indent-guides-auto-enabled nil)
  (set-face-background 'highlight-indent-guides-character-face "light yellow")
  (set-face-foreground 'highlight-indent-guides-character-face "light yellow")
  (set-face-background 'highlight-indent-guides-top-character-face "light yellow")
  (set-face-foreground 'highlight-indent-guides-top-character-face "gray"))


;; jedi.el -- Autocompletion for python
;;
;; On first install, the following needs to be run within Emacs:
;;
;;   M-x jedi:install-server RET
(use-package jedi
  :after (epc popup)
  :ensure t
  :hook ((python-mode) . jedi:setup) 
  :init
  (add-to-list 'ac-sources 'ac-source-jedi-direct)
  :config
  (setq jedi:complete-on-dot t
        jedi:tooltip-method '(popup)))


(use-package json-mode
  :ensure t
  :mode "\\.json\\'" "\\.json.j2\\'"
  :init
  (setq js-indent-level 2))


;; Allows browser preview with C-c C-c v
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-command "pandoc"))


(use-package magit
  :ensure t)


(use-package neotree
  :ensure t
  :init
  (setq neo-hidden-regexp-list '("^\\."
                                 "\\.cs\\.meta$"
                                 "\\.pyc$"
                                 "~$"
                                 "^#.*#$"
                                 "\\.elc$"
                                 "^__pycache__$"))
  :config
  (global-set-key [f8] 'neotree-toggle)
  (setq neo-smart-open t)
  (neotree-toggle))


(use-package org
  :ensure t
  :init
  (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
  :config
  (setq org-support-shift-select t))


(use-package plantuml-mode
  :if (not (version< emacs-version "25.0"))
  :ensure t
  :init
  (setq plantuml-jar-path "/usr/share/plantuml/plantuml.jar"))


;; For Flycheck: pip install flake8
(use-package python
  :ensure t
  :config
  (when (executable-find "ipython")
    (setq python-shell-interpreter "ipython"
          python-shell-interpreter-args "-i"))

  ;; Remove trailing whitespace on save
  (defun remove-whitespaces ()
    (add-hook 'local-write-file-hooks
              '(lambda () (save-excursion (delete-trailing-whitespace)))))
  (defun my-python-mode-hook ()
    (remove-whitespaces))
  (add-hook 'python-mode-hook 'my-python-mode-hook))


(use-package sql-upcase
  :init
  (ensure-downloaded-file
   "https://raw.githubusercontent.com/emacsmirror/emacswiki.org/master/sql-upcase.el"
   (concat my-lispdir "sql-upcase.el"))
  :hook ((sql-mode sql-interactive-mode) . sql-upcase-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; web-mode for JavaScript, HTML, and CSS
;;
;; For linters, install the following:
;;
;;   $ sudo npm install -g eslint babel-eslint eslint-plugin-react
;;   $ sudo apt install tidy
;;   $ sudo npm install -g csslint
;;
(use-package web-mode
  :ensure t
  :mode "\\.css\\'" "\\.html?\\'" "\\.js\\'"
  :init
  (setq web-mode-code-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-markup-indent-offset 2
        web-mode-script-padding 2
        web-mode-style-padding 2)
  (add-to-list web-mode-ac-sources-alist
               '(("css", (ac-sources-css-property))
                 ("html", (ac-source-words-in-buffer
                           ac-source-abbrev))))
  :config
  (defun my-web-mode-hook ()
    (cond ((string= web-mode-content-type "html")
           (when (executable-find "tidy")
             (flycheck-select-checker 'html-tidy)))
          ((string= web-mode-content-type "css")
           (when (executable-find "csslint")
             (flycheck-select-checker 'css-css-lint)))
          ((or (string= web-mode-content-type "javascript")
               (string= web-mode-content-type "jsx"))
           (when (executable-find "eslint")
             (flycheck-select-checker 'javascript-eslint))
           (web-mode-set-content-type "jsx"))))
  (add-hook 'web-mode-hook 'my-web-mode-hook)

  (require 'flycheck)
  
  ;; Disable checkers not in use
  (setq-default flycheck-disabled-checkers
                (append flycheck-disabled-checkers '(json-jsonlist)))
  (setq-default flycheck-disabled-checkers
                (append flycheck-disabled-checkers '(javascript-jshint)))

  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-mode 'html-tidy 'web-mode)
  (flycheck-add-mode 'css-csslint 'web-mode))


(use-package yaml-mode
  :ensure t
  :mode "\\.ya?ml\\'" "\\.ya?ml.j2\\'")


(provide 'init)
;;; init.el ends here

