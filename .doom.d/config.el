;;; $DOOMDIR/config.el -*- lexical-binding: t; +ligatures-in-modes: nil -*-

;; ligatures-in-modes: nil  ;; disable ligatures when editing this file -- it's too slow here

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setf doom-font (font-spec :family "Pragmata Pro" :weight 'regular :height 130.0)
      doom-variable-pitch-font (font-spec :family "Cantarell" :weight 'regular :height 130.0 :inherit 'default))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

(setq doom-theme 'typo-dark)

;; no thank you, delete-selection-mode (doom default: on)
(setf delete-selection-mode -1)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Disable line numbers for some modes
;; - [ ] TODO don't do this every time - do it once.  add a guard variable
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))


;; we're not interested in global-company-mode in org buffers for now:
(setf company-global-modes '(not
                             erc-mode
                             message-mode
                             help-mode
                             gud-mode
                             org-mode
                             yaml-mode))

(add-hook 'log-edit-mode-hook (lambda () (company-mode 0)))

;; another attempt to variable-pitchify org more
;; via: https://www.reddit.com/r/emacs/comments/8838hk/orgvariablepitchel_variablepitch_in_org_mode_but/
;; (add-hook 'org-mode-hook
;;             '(lambda ()
;;                (variable-pitch-mode 1)
;;                (mapc
;;                 (lambda (face) ;; Rescale and inherit the properties from the fixed-pitch font.
;;                   (set-face-attribute face nil :inherit 'fixed-pitch))
;;                 (list 'org-code 'org-link 'org-block 'org-table 'org-property-value 'org-formula
;;                       'org-tag 'org-verbatim 'org-date 'company-tooltip
;;                       'org-special-keyword 'org-block-begin-line
;;                       'org-block-end-line 'org-meta-line
;;                       'org-document-info-keyword))))


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(after! workspaces
  (progn
    ;; these guys interrupt emacsclient 'C-x #' or 'C-x 5 0' with persp windowsize errors
    (remove-hook 'server-done-hook #'+workspaces-delete-associated-workspace-h)
    (remove-hook 'delete-fram-functions #'+workspaces-delete-associated-workspace-h)))

(after! ibuffer
  ;; nearly all of this is the default layout
  (setq ibuffer-formats
      '((mark modified read-only " "
              (name 30 30 :left :elide) ; change: 30s were originally 18s
              " "
              (size 9 -1 :right)
              " "
              (mode 16 16 :left :elide)
              " " filename-and-process)
        (mark " "
              (name 16 -1)
              " " filename))))

;; "unreal" buffers, explained:
;; - https://github.com/hlissner/doom-emacs/issues/3495#issuecomment-667291756
;; escape hatch, if we're ever annoyed by this too much:
;; (setq doom-unreal-buffer-functions '(minibufferp))

(after! vterm
  (progn
    (setf vterm-shell "/bin/bash -l")

    ;; docs say when this is not nil, vterm auto-renames own buffers with 'vterm-buffer-name-string'
    ;; our problem has been 'vterm-buffer-name' is undefined... maybe it needs to be nil?
    ;;
    ;; why is this a thing?
    ;; (setf vterm-buffer-name "*doom:vterm-popup:%s*")
    ;; (setf vterm-buffer-name-string "%s")

    ;; (global-set-key [f2] 'vterm-toggle)
    ;; (global-set-key [C-f2] 'vterm-toggle-cd)
    ;;    (global-set-key [f2] (lambda () (interactive) (+vterm/toggle nil)))
    ;;    (define-key vterm-mode-map [f2] (lambda () (interactive) (+vterm/toggle nil)))


    ;; you can cd to the directory where your previous buffer file exists
    ;; after you have toggle to the vterm buffer with `vterm-toggle'.
    (define-key vterm-mode-map [(control return)]   #'vterm-toggle-insert-cd)
    ;Switch to next vterm buffer
    (define-key vterm-mode-map (kbd "s-n")   'vterm-toggle-forward)
    ;Switch to previous vterm buffer
    (define-key vterm-mode-map (kbd "s-p")   'vterm-toggle-backward)

    (define-key vterm-mode-map [(control meta next)] 'scroll-up)
    (define-key vterm-mode-map [(control meta prior)] 'scroll-down)

    ;; we were having trouble restoring the mode line in vterm windows
    ;; not yet clear if we need both this, and the (set-popup-rule!... :modeline t)
    (remove-hook 'vterm-mode-hook 'hide-mode-line-mode)
    ;; vterm-mode-hook contents:
    ;; (doom--setq-hscroll-margin-for-vterm-mode-h
    ;;  doom--setq-confirm-kill-processes-for-vterm-mode-h
    ;;  vterm-toggle--mode-hook
    ;;  hide-mode-line-mode
    ;;  doom-mark-buffer-as-real-h)

    ;; investigate +popup-buffer-mode-hook

    ;; consider if we want to override the default
    ;; (setf vterm-term-environment-variable "xterm-256color")

    (require 'vterm-toggle)

    ))

(after! vterm-toggle
  (progn
    ;; this may belong in vterm?
    ; vterm popup should appear on ':side right'
    (set-popup-rule! ".*vterm.*" :size 0.25 :vslot -4 :select t :quit nil :ttl 0 :side 'right :modeline t)

    (defvar vterm-buffer-name 'nil "I guess vterm-toggle forgot to define this?")
    (setf vterm-toggle-fullscreen-p nil)
    (setf vterm-toggle-hide-method 'reset-window-configration) ; [sic] engrish
    (setf vterm-toggle-scope 'project)))

    ;; ("s-t" . #'vterm) ; Open up new tabs quickly

(map! :after vterm-toggle
      [f2] (lambda () (interactive) (let
                                                 ((vterm-buffer-name
                                                   (format "*doom:vterm-popup:%s*"
                                                           (if (bound-and-true-p persp-mod)
                                                               (safe-persp-name (get-current-persp))
                                                             "main"))))
                                               (vterm-toggle))))
(map! :after vterm-toggle
      :map vterm-mode-map
      ;; since we generally use vterm-toggle to create/hide our terms... the naming scheme for those happens here
      ;; if you want M-x vterm buffer naming, you'll have to set vterm-buffer-name
      [f2] 'vterm-toggle)


(after! ivy
  (progn
    (setf ivy-magic-tilde nil))) ;; don't be surprised by '~', require '~/'

(after! org
  (progn
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((dot . t)) ; this line activates dot
    )))

(defun mt/org-mode-setup ()
  (message "mt/org-mode-setup-hook")
  (org-indent-mode)
  (org-bullets-mode 1)
  (variable-pitch-mode 1)
  (org-display-inline-images)

  ;; bind company-complete-at-point to a key if, perhaps we need it?
  ;; (local-set-key "C-<tab>" 'company-complete-common) needs company-mode temporarily "on"
  )

;; from https://github.com/hlissner/doom-emacs/blob/develop/modules/lang/org/config.el
(defun +org-init-capture-defaults-h ()
  "Sets up some reasonable defaults, as well as two `org-capture' workflows that
I like:
1. The traditional way: invoking `org-capture' directly, via SPC X, or through
   the :cap ex command.
2. Through a org-capture popup frame that is invoked from outside Emacs (the
   ~/.emacs.d/bin/org-capture script). This can be invoked from qutebrowser,
   vimperator, dmenu or a global keybinding."
  (setq org-default-notes-file
        (expand-file-name +org-capture-notes-file org-directory)
        +org-capture-journal-file
        (expand-file-name +org-capture-journal-file org-directory)
        org-capture-templates
        '(("t" "Personal todo" entry
           (file+headline +org-capture-todo-file "Inbox")
           "* [ ] %?\n%i\n%a" :prepend t)
          ("n" "Personal notes" entry
           (file+headline +org-capture-notes-file "Inbox")
           "* %u %?\n%i" :prepend nil)
          ("j" "Journal" entry
           (file+olp+datetree +org-capture-journal-file)
           "* %U %?\n%i\n%a" :prepend t)

          ;; Will use {project-root}/{todo,notes,changelog}.org, unless a
          ;; {todo,notes,changelog}.org file is found in a parent directory.
          ;; Uses the basename from `+org-capture-todo-file',
          ;; `+org-capture-changelog-file' and `+org-capture-notes-file'.
          ("p" "Templates for projects")
          ("pt" "Project-local todo" entry  ; {project-root}/todo.org
           (file+headline +org-capture-project-todo-file "Inbox")
           "* TODO %?\n%i\n%a" :prepend t)
          ("pn" "Project-local notes" entry  ; {project-root}/notes.org
           (file+headline +org-capture-project-notes-file "Inbox")
           "* %U %?\n%i\n%a" :prepend t)
          ("pc" "Project-local changelog" entry  ; {project-root}/changelog.org
           (file+headline +org-capture-project-changelog-file "Unreleased")
           "* %U %?\n%i\n%a" :prepend t)

          ;; Will use {org-directory}/{+org-capture-projects-file} and store
          ;; these under {ProjectName}/{Tasks,Notes,Changelog} headings. They
          ;; support `:parents' to specify what headings to put them under, e.g.
          ;; :parents ("Projects")
          ("o" "Centralized templates for projects")
          ("ot" "Project todo" entry
           (function +org-capture-central-project-todo-file)
           "* TODO %?\n %i\n %a"
           :heading "Tasks"
           :prepend nil)
          ("on" "Project notes" entry
           (function +org-capture-central-project-notes-file)
           "* %U %?\n %i\n %a"
           :heading "Notes"
           :prepend t)
          ("oc" "Project changelog" entry
           (function +org-capture-central-project-changelog-file)
           "* %U %?\n %i\n %a"
           :heading "Changelog"
           :prepend t))))

(use-package! org
  :hook
  (org-mode . mt/org-mode-setup)
  (org-mode . visual-line-mode)

  :config
  (progn
    (setf org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●" "✸" "✿"))
    (setf org-ellipsis " ⯆")  ;; possibly want to move to "mixed-pitch" package?
    ;; from emacs-from-scratch #5 https://www.youtube.com/watch?v=VcgjTEa0kU4
    (font-lock-add-keywords 'org-mode
                            '(("^ *\\([-]\\) "
                               (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
    )

)

;; without this, exwm randr support remains "unactivated"
;;
(after! exwm
  (progn
    (require 'exwm-randr)
    (exwm-randr-enable)
    (exwm-init)
    )
)

(setq exwm-input-global-keys
      `(
        ;; Reset to line mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
        ([?\s-r] . exwm-reset)

         ;; Move between windows
        ([s-left] . windmove-left)
        ([s-right] . windmove-right)
        ([s-up] . windmove-up)
        ([s-down] . windmove-down)

        ;; Lauch apps via shell command, hiding stdout
        ([?\s-&] . (lambda (command)
                     (interactive (list (read-shell-command "$ ")))
                     (start-process-shell-command command nil command)))

        ;; Switch workspace
        ([?\s-w] . exwm-workspace-switch)

        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))
        ))

;; - [ ] TODO insert code for setting Buffer title to X-window title
;;

;; we can't use (!after exwm...), since by then exwm has already loaded our keymap.
;; ## these shell-commands should only run if we're also running exwm:
(call-process-shell-command "xmodmap ~/.xmodmaprc")
(call-process-shell-command "xrdb -merge ~/.Xresources")

(after! ligatures
  (progn
    (setf +ligatures-composition-alist
      '((?!  . "\\(?:!\\(?:==\\|[!=]\\)\\)")                                      ; (regexp-opt '("!!" "!=" "!=="))
        (?#  . "\\(?:#\\(?:###?\\|_(\\|[#(:=?[_{]\\)\\)")                         ; (regexp-opt '("##" "###" "####" "#(" "#:" "#=" "#?" "#[" "#_" "#_(" "#{"))
        (?$  . "\\(?:\\$>>?\\)")                                                  ; (regexp-opt '("$>" "$>>"))
        (?%  . "\\(?:%%%?\\)")                                                    ; (regexp-opt '("%%" "%%%"))
        (?&  . "\\(?:&&&?\\)")                                                    ; (regexp-opt '("&&" "&&&"))
        (?*  . "\\(?:\\*\\(?:\\*[*/]\\|[)*/>]\\)?\\)")                            ; (regexp-opt '("*" "**" "***" "**/" "*/" "*>" "*)"))
        (?+  . "\\(?:\\+\\(?:\\+\\+\\|[+:>]\\)?\\)")                              ; (regexp-opt '("+" "++" "+++" "+>" "+:"))
        (?-  . "\\(?:-\\(?:-\\(?:-?>\\)\\|<[<-]\\|>[>-]\\|[:<>|}~]\\)\\)")        ; (regexp-opt '("-->" "--->" "->-" "-<" "-<-" "-<<" "->" "->>" "-}" "-~" "-:" "-|"))
        ;; (?-  . "\\(?:-\\(?:-\\(?:->\\|[>-]\\)\\|<[<-]\\|>[>-]\\|[:<>|}~-]\\)\\)") ; (regexp-opt '("--" "---" "-->" "--->" "->-" "-<" "-<-" "-<<" "->" "->>" "-}" "-~" "-:" "-|"))
        (?.  . "\\(?:\\.\\(?:\\.[.<]\\|[.=>-]\\)\\)")                             ; (regexp-opt '(".-" ".." "..." "..<" ".=" ".>"))
        (?/  . "\\(?:/\\(?:\\*\\*\\|//\\|==\\|[*/=>]\\)\\)")                      ; (regexp-opt '("/*" "/**" "//" "///" "/=" "/==" "/>"))
        (?:  . "\\(?::\\(?:::\\|[+:<=>]\\)?\\)")                                  ; (regexp-opt '(":" "::" ":::" ":=" ":<" ":=" ":>" ":+"))
        (?\; . ";;")                                                              ; (regexp-opt '(";;"))
        (?0  . "0\\(?:\\(x[a-fA-F0-9]\\).?\\)") ; Tries to match the x in 0xDEADBEEF
        ;; (?x . "x") ; Also tries to match the x in 0xDEADBEEF
        ;; (regexp-opt '("<!--" "<$" "<$>" "<*" "<*>" "<**>" "<+" "<+>" "<-" "<--" "<---" "<->" "<-->" "<--->" "</" "</>" "<<" "<<-" "<<<" "<<=" "<=" "<=<" "<==" "<=>" "<===>" "<>" "<|" "<|>" "<~" "<~~" "<." "<.>" "<..>"))
        (?<  . "\\(?:<\\(?:!--\\|\\$>\\|\\*\\(?:\\*?>\\)\\|\\+>\\|-\\(?:-\\(?:->\\|[>-]\\)\\|[>-]\\)\\|\\.\\(?:\\.?>\\)\\|/>\\|<[<=-]\\|=\\(?:==>\\|[<=>]\\)\\||>\\|~~\\|[$*+./<=>|~-]\\)\\)")
        (?=  . "\\(?:=\\(?:/=\\|:=\\|<<\\|=[=>]\\|>>\\|[=>]\\)\\)")               ; (regexp-opt '("=/=" "=:=" "=<<" "==" "===" "==>" "=>" "=>>"))
        (?>  . "\\(?:>\\(?:->\\|=>\\|>[=>-]\\|[:=>-]\\)\\)")                      ; (regexp-opt '(">-" ">->" ">:" ">=" ">=>" ">>" ">>-" ">>=" ">>>"))
        (??  . "\\(?:\\?[.:=?]\\)")                                               ; (regexp-opt '("??" "?." "?:" "?="))
        (?\[ . "\\(?:\\[\\(?:|]\\|[]|]\\)\\)")                                    ; (regexp-opt '("[]" "[|]" "[|"))
        (?\\ . "\\(?:\\\\\\\\[\\n]?\\)")                                          ; (regexp-opt '("\\\\" "\\\\\\" "\\\\n"))
        (?^  . "\\(?:\\^==?\\)")                                                  ; (regexp-opt '("^=" "^=="))
        (?w  . "\\(?:wwww?\\)")                                                   ; (regexp-opt '("www" "wwww"))
        (?{  . "\\(?:{\\(?:|\\(?:|}\\|[|}]\\)\\|[|-]\\)\\)")                      ; (regexp-opt '("{-" "{|" "{||" "{|}" "{||}"))
        (?|  . "\\(?:|\\(?:->\\|=>\\||=\\|[]=>|}-]\\)\\)")                        ; (regexp-opt '("|=" "|>" "||" "||=" "|->" "|=>" "|]" "|}" "|-"))
        (?_  . "\\(?:_\\(?:|?_\\)\\)")                                            ; (regexp-opt '("_|_" "__"))
        (?\( . "\\(?:(\\*\\)")                                                    ; (regexp-opt '("(*"))
        (?~  . "\\(?:~\\(?:~>\\|[=>@~-]\\)\\)"))                                  ; (regexp-opt '("~-" "~=" "~>" "~@" "~~" "~~>"))
      )))

;;;; kitty - can't directly map command to meta?
;;;; so we have to map these?
(define-key key-translation-map (kbd "M-[ 4 4   ; 1 0 u") (kbd "M-<")) ; cmd+shift+<
(define-key key-translation-map (kbd "M-[ 4 6   ; 1 0 u") (kbd "M->")) ; cmd+shift+>

; cmd+<char>
(define-key key-translation-map (kbd "M-[ 4 8   ;   9 u") (kbd "M-0"))
(define-key key-translation-map (kbd "M-[ 4 9   ;   9 u") (kbd "M-1"))
(define-key key-translation-map (kbd "M-[ 5 0   ;   9 u") (kbd "M-2"))
(define-key key-translation-map (kbd "M-[ 5 1   ;   9 u") (kbd "M-3"))
(define-key key-translation-map (kbd "M-[ 5 2   ;   9 u") (kbd "M-4"))
(define-key key-translation-map (kbd "M-[ 5 3   ;   9 u") (kbd "M-5"))
(define-key key-translation-map (kbd "M-[ 5 4   ;   9 u") (kbd "M-6"))
(define-key key-translation-map (kbd "M-[ 5 5   ;   9 u") (kbd "M-7"))
(define-key key-translation-map (kbd "M-[ 5 6   ;   9 u") (kbd "M-8"))
(define-key key-translation-map (kbd "M-[ 5 7   ;   9 u") (kbd "M-9"))
(define-key key-translation-map (kbd "M-[ 5 8   ;   9 u") (kbd "M-:"))
(define-key key-translation-map (kbd "M-[ 5 9   ;   9 u") (kbd "M-;"))

(define-key key-translation-map (kbd "M-[ 9 7   ;   9 u") (kbd "M-a"))
(define-key key-translation-map (kbd "M-[ 9 8   ;   9 u") (kbd "M-b"))
(define-key key-translation-map (kbd "M-[ 9 9   ;   9 u") (kbd "M-c"))
(define-key key-translation-map (kbd "M-[ 1 0 0 ;   9 u") (kbd "M-d"))
(define-key key-translation-map (kbd "M-[ 1 0 1 ;   9 u") (kbd "M-e"))
(define-key key-translation-map (kbd "M-[ 1 0 2 ;   9 u") (kbd "M-f"))
(define-key key-translation-map (kbd "M-[ 1 0 3 ;   9 u") (kbd "M-g"))
(define-key key-translation-map (kbd "M-[ 1 0 4 ;   9 u") (kbd "M-h"))
(define-key key-translation-map (kbd "M-[ 1 0 5 ;   9 u") (kbd "M-i"))
(define-key key-translation-map (kbd "M-[ 1 0 6 ;   9 u") (kbd "M-j"))
(define-key key-translation-map (kbd "M-[ 1 0 7 ;   9 u") (kbd "M-k"))
(define-key key-translation-map (kbd "M-[ 1 0 8 ;   9 u") (kbd "M-l"))
(define-key key-translation-map (kbd "M-[ 1 0 9 ;   9 u") (kbd "M-m"))
(define-key key-translation-map (kbd "M-[ 1 1 0 ;   9 u") (kbd "M-n"))
(define-key key-translation-map (kbd "M-[ 1 1 1 ;   9 u") (kbd "M-o"))
(define-key key-translation-map (kbd "M-[ 1 1 2 ;   9 u") (kbd "M-p"))
(define-key key-translation-map (kbd "M-[ 1 1 3 ;   9 u") (kbd "M-q"))
(define-key key-translation-map (kbd "M-[ 1 1 4 ;   9 u") (kbd "M-r"))
(define-key key-translation-map (kbd "M-[ 1 1 5 ;   9 u") (kbd "M-s"))
(define-key key-translation-map (kbd "M-[ 1 1 6 ;   9 u") (kbd "M-t"))
(define-key key-translation-map (kbd "M-[ 1 1 7 ;   9 u") (kbd "M-u"))
(define-key key-translation-map (kbd "M-[ 1 1 8 ;   9 u") (kbd "M-v"))
(define-key key-translation-map (kbd "M-[ 1 1 9 ;   9 u") (kbd "M-w"))
(define-key key-translation-map (kbd "M-[ 1 2 0 ;   9 u") (kbd "M-x"))
(define-key key-translation-map (kbd "M-[ 1 2 1 ;   9 u") (kbd "M-y"))
(define-key key-translation-map (kbd "M-[ 1 2 2 ;   9 u") (kbd "M-z"))

(define-key key-translation-map (kbd "M-[     1 ;   9 a") (kbd "M-<up>"))
(define-key key-translation-map (kbd "M-[     1 ;   9 b") (kbd "M-<down>"))
(define-key key-translation-map (kbd "M-[     1 ;   9 c") (kbd "M-<right>"))
(define-key key-translation-map (kbd "M-[     1 ;   9 d") (kbd "M-<left>"))
(define-key key-translation-map (kbd "M-[     1 ;   9 A") (kbd "M-<up>"))
(define-key key-translation-map (kbd "M-[     1 ;   9 B") (kbd "M-<down>"))
(define-key key-translation-map (kbd "M-[     1 ;   9 C") (kbd "M-<right>"))
(define-key key-translation-map (kbd "M-[     1 ;   9 D") (kbd "M-<left>"))
