;; TODO plan - have .emacs.d as repo base
;; commit init.el only
;; include one liner to curl/emacs it down to machine.

(setq gc-cons-threshold 32000000      ;; 32 MB
      garbage-collectionn-messages t) ;; indicator of thrashing

;; TODO make graceful failure for deps (e.g no internet or melpa)

(prefer-coding-system 'utf-8)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(fringe-mode -1)
(show-paren-mode 1)
(electric-pair-mode 1)
(electric-indent-mode 1)
(global-auto-revert-mode 1)
(savehist-mode 1) ;; save minibuffer commands between sessions
(ido-mode t)
(setq-default
 split-height-threshold 1200
 split-width-threshold 2000
 debug-on-error t
 inhibit-splash-screen t
 vc-follow-symlinks t
 column-number-mode t
 ido-enable-flex-matching t
 load-prefer-newer t
 fill-column 80
 compilation-ask-about-save nil
 backup-directory-alist `(("." . ,(concat user-emacs-directory "saves")))
 custom-file (make-temp-file ""))
;; TODO 14 for laptop, 8 for 1440p work
(ignore-errors (set-frame-font "xos4 Terminus-14"))
(defalias 'yes-or-no-p 'y-or-n-p)

;; Initialize package manager
(require 'package)
(add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)
(package-initialize)

;; Macros
(defmacro ifn (fn)
  `(lambda () (interactive) ,fn))

(defmacro include (name &rest args)
  `(progn
     (unless (assoc ',name package-archive-contents)
       (package-refresh-contents))
     (unless (package-installed-p ',name)
       (package-install ',name))
     (require ',name)))

(dolist
    (binding
     `(("M-o" . other-window)
       ("C-c i" . ,(ifn (find-file (concat user-emacs-directory "init.el"))))
       ("C-c n" . ,(ifn (find-file (concat user-emacs-directory "notes.org"))))
       ("C-c g" . magit)
       ("C-c p" . projectile-find-file)
       ("C-c P" . projectile-grep)
       ("C-h" . delete-backward-char)
       ("M-H" . ,help-map)
       ("C-;" . company-capf)
       ("M-k" . paredit-forward-barf-sexp)
       ("M-l" . paredit-forward-slurp-sexp)
       ("M-RET" . toggle-frame-fullscreen)))
  (global-set-key (kbd (car binding)) (cdr binding)))

(add-hook 'ido-setup-hook
	  (lambda ()
	    (define-key ido-completion-map (kbd "C-w") 'backward-kill-word)
	    (define-key ido-file-completion-map (kbd "C-w") 'ido-delete-backward-word-updir)))

(include paredit)
(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'clojure-mode-hook #'enable-paredit-mode)
(defadvice he-substitute-string (after he-pparedit-fix)
  "remove extra paren when expanding line in paredit"
  (if (and paredit-mode (equal (substring str -1) (or ")" "]" "}")))
      (progn (backward-delete-char 1) (forward-char))))

(include magit)

(include company)
(add-hook 'after-init-hook 'global-company-mode)

(include lsp-mode)
;; (include lsp-ui)
;; (add-hook 'lsp-mode-hook 'lsp-ui-mode)
(include company-lsp)
(push 'company-lsp company-backends)
;; TODO clojure-lsp (no cider?)
;; TODO lsp-java
;; TODO trial in code-mode-hook
;; (add-hook 'html-code-hook #'lsp)

;; be aware that company-capf does not seem to complete on - words
;; e.g max(hit complete) works but max-(hit complete) does not.
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection '("tailwindcss-language-server" "--stdio"))
		  :major-modes '(mhtml-mode)
		  :server-id 'tailwind))

;; (include lsp-ui)

(include projectile)

;; proxies (should be removed by cntlm)

;; more TODOs

(defadvice kill-region (before unix-werase activate compile)
  "When called interactively with no active region, delete a single word
    backwards instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (save-excursion (backward-word 1) (point)) (point)))))



(include clojure-mode)
;; (include inf-clojure)
(include cider)

(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook #'enable-paredit-mode)
(add-hook 'clojure-mode-hook #'enable-paredit-mode)

(defun code-config ()
  (if (version<= "26.0.50" emacs-version)
      (display-line-numbers-mode 1)
      (linum-mode 1)))

(dolist
    (hook
     '(prog-mode-hook
       css-mode-hook))
  (add-hook hook 'code-config))

;; themes

;; (include doom-theme)
(include color-theme-sanityinc-tomorrow)
(load-theme 'sanityinc-tomorrow-bright t)
;; (include poet-theme)
;; (include dracula-theme)
;; (include gotham-theme)
;; laguna solarized nightowl monokai monokai-pro
;; see peach melpa for more!
;; (load-theme 'tango-dark t)

