;; %%%%%%%%%% Emacs init file of Gian Fontanilla %%%%%%%%%%

;; %%%%%%%%%% Start of Emacs Lisp functions %%%%%%%%%%

(defun skipc ()
  "Skip whitespaces and sentence end punctuation marks."
  (interactive)
  (skip-chars-forward " \t\n\r.!?"))

;; (define-key global-map "\M-s" `skipc)

(defun set-as-last-kbd-macro (macro &optional keys)
  "Sets the variable `last-kbd-macro' to the keyboard macro
`MACRO'."
  (interactive 
   (list 
    (intern 
     (completing-read "Enter kbd macro: "
		      obarray
		      (lambda (elt)
			(and (fboundp elt)
			     (or (stringp (symbol-function elt))
				 (vectorp (symbol-function elt))
				 (get elt 'kmacro))))
		      t))
	 current-prefix-arg))
  (set 'last-kbd-macro macro))

(defun insert-org-meeting-header ()
  "Insert header in meeting file with the current date; asks for
meeting name and place."
  (interactive)  
  (insert (concat "=== " 
		  (trim-string (read-from-minibuffer "Meeting name: "))
		  " -- " 
		  (trim-string (shell-command-to-string "date +\"%B %e, %Y\"")) 
		  " --- " 
		  (trim-string (read-from-minibuffer "Meeting place: "))
		  " ===")))

(defun trim-string (string)
  "Remove white spaces in beginning and end of STRING. White space
can be: space, tab, emacs newline (line feed, ASCII 10)."
  (replace-regexp-in-string "\\`[ \t\n]*" "" 
			    (replace-regexp-in-string "[ \t\n]*\\'" "" string)))

(defun count-whatever-region (apply-func start end &optional unit)
  "Count number of words or sentences or anything in region specified
by START and END; print a message in the minibuffer with the result.

APPLY-FUNC specifies which function to apply for counting:
typically either `forward-word' or `forward-sentence'. If UNIT
was not specified, use the term \"unit\"."
  (save-excursion
    (let ((count 0) (temp 0))
      (goto-char start)
      ;; Use the generic unit "units" if unspecified
      (if (eq unit nil)
	  (setq unit "unit"))
      (skipc)
      (while (< (point) end)
	(apply (symbol-function apply-func) '(1))
	(setq count (1+ count))
	(skipc))
      (message (concat 
		(if (boundp 'whole-buffer)
		    "Buffer"
		  "Region") 
		" contains %d %s(s).") count unit))))

(defun count-words-region (start end)
  "Count number of words in the region; print a message in the
minibuffer with the result.

This function relies on the function `count-whatever-region'."
  (interactive "r")
  (count-whatever-region 'forward-word start end "word"))

(defun count-sentences-region (start end)
  "Count number of words in the region; print a message in the
minibuffer with the result.

This function relies on the function `count-whatever-region'."
  (interactive "r")
  (count-whatever-region 'forward-sentence start end "sentence"))

(defun count-words-buffer ()
  "Count number of words in the current buffer; print a message
in the minibuffer with the result.

This function relies on the function `count-words-region'."
  (interactive)
  (let (whole-buffer)
    (count-words-region (point-min) (point-max))))

(defun count-sentences-buffer ()
  "Count number of sentences in the current buffer; print a
message in the minibuffer with the result.

This function relies on the function `count-sentences-region'."
  (interactive)
  (let (whole-buffer)
    (count-sentences-region (point-min) (point-max))))

(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (shell-command
   (format "cd %s; ctags --verbose -e -R --extra=+fq --exclude=db --exclude=test --exclude=.git --exclude=public -f %s &"
	   dir-name (concat dir-name "TAGS"))))

;; %%%%%%%%%% End of Emacs Lisp functions %%%%%%%%%%

;; ============================================================
;; Keyboard mapping
;; ============================================================

(define-key global-map "\C-h" 'backward-delete-char-untabify)

(global-set-key [(shift delete)] 'clipboard-kill-region)
(global-set-key [(control insert)] 'clipboard-kill-ring-save)
(global-set-key [(shift insert)] 'clipboard-yank)

;; ============================================================
;; Enable auto-complete-mode
;; ============================================================

(add-to-list 'load-path "~/.emacs.d/auto-complete/")
(require 'auto-complete)

(add-to-list 'ac-dictionary-directories "~/emacs.d/auto-complete/dict/")
(require 'auto-complete-config)
(ac-config-default)
(add-hook 'emacs-lisp-mode-hook (lambda ()
				  (ac-emacs-lisp-mode-setup)
				  (auto-complete-mode t)
				  ))
(add-to-list `ac-modes `ruby-mode)

;; ============================================================
;; Enable built-in modes automatically
;; ============================================================

;;(iswitchb-mode 1)
;;(column-number-mode 1)
;;(mouse-avoidance-mode 'banish)
(show-paren-mode 1)
(ido-mode 1)
(icomplete-mode 1)

;; ============================================================
;; Enable orgtbl-mode when opening .orgtbl files
;; ============================================================

(add-to-list 'auto-mode-alist '("\\.orgtbl\\'" . orgtbl-mode))

;; ============================================================
;; Enable remember for org-mode
;; ============================================================

(org-remember-insinuate)
(setq org-directory "~/Documents/MISC/orgdata")
(setq org-default-notes-file (concat org-directory "/notes.org"))
(define-key global-map "\C-cr" `org-remember)

(defun org-open-default-notes-file () 
  "Opens the default notes file."
  (interactive)
  (find-file org-default-notes-file))

(define-key global-map "\C-ck" `org-open-default-notes-file)

;; ============================================================
;; Enable ace-jump-mode
;; ============================================================

(add-to-list 'load-path "~/.emacs.d/ace-jump-mode/")
(autoload 'ace-jump-mode "ace-jump-mode" "Emacs quick move minor mode" t)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

(autoload 'ace-jump-mode-pop-mark "ace-jump-mode" "Ace jump back:-)" t)
(eval-after-load "ace-jump-mode"  
  '(ace-jump-mode-enable-mark-sync))
(define-key global-map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)

;; ============================================================
;; Enable flex-matching for ido-mode
;; ============================================================

(ido-everywhere 1)
;;(ido-enable-flex-matching t)

;; ============================================================
;; Enable browse-kill-ring
;; ============================================================
(add-to-list 'load-path "~/.emacs.d/browse-kill-ring")
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; ============================================================
;; Enable multiple-cursors-mode
;; ============================================================

(add-to-list 'load-path "~/.emacs.d/multiple-cursors-mode/")
(require 'multiple-cursors)

(global-set-key (kbd "C-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; ============================================================
;; Enable magit
;; ============================================================

(add-to-list 'load-path "~/.emacs.d/git-modes/")
(add-to-list 'load-path "~/.emacs.d/cl-lib/")
(add-to-list 'load-path "~/.emacs.d/magit/")
(require 'magit)

;; Prevent `magit-auto-revert-mode warning from showing up
(setq magit-last-seen-setup-instructions "1.4.0")

;; ============================================================
;; Enable yasnippet
;; ============================================================

(add-to-list 'load-path "~/.emacs.d/yasnippet")
(require 'yasnippet)

(yas/initialize)
(yas/load-directory "~/.emacs.d/yasnippet/snippets")

;; ============================================================
;; Enable expand-region
;; ============================================================

(add-to-list 'load-path "~/.emacs.d/expand-region/")
(require 'expand-region)
(global-set-key (kbd "C-@") 'er/expand-region)
(global-set-key (kbd "C-M-@") 'er/contract-region)

;; ============================================================
;; Enable json-reformat
;; ============================================================
(load "~/.emacs.d/json-reformat/json-reformat.el")

;; ============================================================
;; Enable json-snatcher
;; ============================================================
(load "~/.emacs.d/json-snatcher/json-snatcher.el")

;; ============================================================
;; Enable json-mode
;; ============================================================
(load "~/.emacs.d/json-mode/json-mode.el")

;; ============================================================
;; Enable restclient
;; ============================================================
(add-to-list 'load-path "~/.emacs.d/restclient/")
(require 'restclient)

;; ============================================================
;; Enable sublimity
;; ============================================================

(add-to-list 'load-path "~/.emacs.d/sublimity/")
(require 'sublimity)
;; (require 'sublimity-scroll)
(require 'sublimity-map)
(sublimity-mode 0) ;; don't use immediately
(global-set-key [f9] 'sublimity-global-mode)

;; ============================================================
;; Enable nXhtml and php-mode
;; ============================================================
(load "~/.emacs.d/nxhtml/autostart.el")

(autoload 'php-mode "php-mode" "Major mode for editing php code." t)
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))

;; ============================================================
;; Enable inf-ruby and rinari
;; ============================================================
(add-to-list 'load-path "~/.emacs.d/rinari")
(require 'rinari)
(add-hook 'ruby-mode-hook 'rinari-launch)

(require 'mumamo-fun)
(setq mumamo-chunk-coloring 'submode-colored)
(add-to-list 'auto-mode-alist '("\\.rhtml\\'" . eruby-html-mumamo))
(add-to-list 'auto-mode-alist '("\\.html\\.erb\\'" . eruby-html-mumamo))

(load "~/.emacs.d/exec-path-from-shell.el")
(require 'exec-path-from-shell)
(exec-path-from-shell-initialize)

;; Override to use "bundle exec rake"
(defun ruby-compilation-rake (&optional edit task env-vars)
  "Run a rake process dumping output to a ruby compilation buffer."
  (interactive "P")
  (let* ((task (concat
                (or task (if (stringp edit) edit)
                    (completing-read "Rake: " (pcmpl-rake-tasks)))
                " "
                (mapconcat (lambda (pair)
                             (format "%s=%s" (car pair) (cdr pair)))
                           env-vars " ")))
         (rake-args (if (and edit (not (stringp edit)))
                        (read-from-minibuffer "Edit Rake Command: " (concat task " "))
                      task)))
    (pop-to-buffer (ruby-compilation-do
                    "rake" (nconc '("bundle" "exec" "rake")
                                  (split-string rake-args))))))
(ad-activate 'ruby-compilation-rake)

(setq ruby-insert-encoding-magic-comment nil)

;; ============================================================
;; Enable readline-complete
;; ============================================================

(setq explicit-shell-file-name "bash")
(setq explicit-bash-args '("-c" "-t" "export EMACS=; stty echo; bash"))
(setq comint-process-echoes t)

(load "~/.emacs.d/readline-complete.el")
(require 'readline-complete)

(add-to-list 'ac-modes 'shell-mode)
(add-hook 'shell-mode-hook 'ac-rlc-setup-sources)

;; ============================================================
;; Enable w3
;; ============================================================
;(add-to-list 'load-path "~/.emacs.d/w3m/")
;(load "~/.emacs.d/w3m/w3m.el")
;(require 'w3m)

;; ============================================================
;; Set frame size
;; ============================================================

(if (window-system) 
    (set-frame-size (selected-frame) 92 52))
