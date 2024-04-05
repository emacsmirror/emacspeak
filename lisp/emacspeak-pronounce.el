;;; emacspeak-pronounce.el --- pronunciations -*- lexical-binding: t; -*-
;;
;; $Author: tv.raman.tv $
;; Description: Emacspeak pronunciation dictionaries
;; Keywords:emacspeak, audio interface to emacs customized pronunciation
;;;  LCD Archive entry:

;; LCD Archive Entry:
;; emacspeak| T. V. Raman |tv.raman.tv@gmail.com
;; A speech interface to Emacs |
;; 
;; $Revision: 4532 $ |
;; Location https://github.com/tvraman/emacspeak
;; 

;;;  Copyright:
;; Copyright (C) 1995 -- 2024, T. V. Raman
;; Copyright (c) 1995 by T. V. Raman
;; All Rights Reserved.
;; 
;; This file is not part of GNU Emacs, but the same permissions apply.
;; 
;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;; 
;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to
;; the Free Software Foundation, 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.



;;; Commentary:
;; This module implements user customizable pronunciation dictionaries
;; for emacspeak. Custom pronunciations can be defined per file, per
;; directory and/or per major mode. Emacspeak maintains a persistent
;; user dictionary upon request and loads these in new emacspeak
;; sessions. This module implements the user interface to the custom
;; dictionary as well as providing the internal API used by the rest
;; of emacspeak in using the dictionary.
;; @subsection Algorithm:

;; The persistent dictionary is a hash table where the hash keys are
;; filenames, directory names, or major-mode names. The hash values
;; are association lists defining the dictionary. Users of this module
;; can retrieve a dictionary made up of all applicable association
;; lists for a given file.
;;; Code:

;;;  required Modules:

(eval-when-compile (require 'cl-lib))
(require 'emacspeak-sounds)
(cl-declaim  (optimize  (safety 0) (speed 3)))

;;; Helper:ems--pronounce-string-template:

;; Helper: split a string using split-pattern and format using format-template

(defun ems--pronounce-string-template (str split template)
  "Return an audio formatted representation of string `STR'.
Split using pattern given by `SPLIT' and format using `TEMPLATE'.
Template is a list:
Number: Select element at position n from splits.
String: Return it as is.
(func number number ...): Apply func treating rest of the list as
  positions into splits."
  (let ((fields (split-string str split))
        (values nil))
    (cl-loop
     for  v in template do
     (push
      (cond
       ((stringp v) (format " %s " v))
       ((and (numberp v) (< v (length fields)))
        (propertize (nth v fields) 'personality voice-smoothen))
       ((and
         (listp v) (symbolp (nth 0 v)) (fboundp (nth 0 v)))
        (apply                          ; apply func to fields
         (nth 0 v)
         (cl-loop for k in (cdr v) collect (nth k fields))))
       (t " "))
      values))
    (mapconcat #'identity (nreverse values) " ")))

;;;  Dictionary structure:

(defvar emacspeak-pronounce-dictionaries (make-hash-table :test #'eq)
  "Hash table  for   pronunciation dictionaries.
Keys are either filenames, directory names, or major mode names.
Values are alists containing string.pronunciation pairs.")

(defun emacspeak-pronounce-set-dictionary (key pr-alist)
  (cl-declare (special emacspeak-pronounce-dictionaries))
  (when (stringp key)
    (setq key (intern key)))
  (setf (gethash key emacspeak-pronounce-dictionaries) pr-alist))

(defun emacspeak-pronounce-get-dictionary (key)
  (cl-declare (special emacspeak-pronounce-dictionaries))
  (when (stringp key) (setq key (intern key)))
  (gethash key emacspeak-pronounce-dictionaries))

(defun emacspeak-pronounce-add-dictionary-entry (key string pronunciation)
  " Adds pronunciation pair STRING.PRONUNCIATION to the dictionary.
Argument KEY specifies a dictionary key e.g. directory, mode etc.
Pronunciation can be a string or a cons-pair.
If it is a string, that string is the new pronunciation.
A cons-pair of the form (matcher . func) results  in 
the match  being passed to the func which returns  the new pronunciation."
  (cl-declare (special emacspeak-pronounce-dictionaries))
  (let* ((dict (emacspeak-pronounce-get-dictionary key))
         (entry (and dict (assoc string dict))))
    (cond
     ((and dict entry)
      (setcdr entry pronunciation))
     (dict
      (setf dict (cons (cons string pronunciation) dict))
      (emacspeak-pronounce-set-dictionary key dict))
     (t
      (emacspeak-pronounce-set-dictionary
       key
       (list (cons string pronunciation)))))))

(defun emacspeak-pronounce-remove-local-entry (string)
  "Remove buffer-specificpronunciation."
  (when (and (boundp 'emacspeak-pronounce-table)
             emacspeak-pronounce-table)
    (remhash string emacspeak-pronounce-table)))

(defun emacspeak-pronounce-add-local-entry (string pronunciation)
  "Add  pronunciation for current buffer. "
  (cl-declare (special emacspeak-pronounce-table))
  (unless emacspeak-pronounce-table
    (setq emacspeak-pronounce-table (emacspeak-pronounce-compose-table)))
  (puthash string pronunciation emacspeak-pronounce-table)
  (when (called-interactively-p 'interactive)
    (message "Added local pronunciation in buffer %s" (buffer-name))))

;;; mode hierarchy per define-derived-mode:

(defun ems--mode-derive-chain (mode)
  "Return mode derivation chain as a list."
  (let ((parents nil))
    (while mode
      (cl-pushnew mode parents)
      (setq mode (get mode  'derived-mode-parent )))
    parents))

;;;  setting up inheritance relations

;; child inherits parents dictionary
;; parent stored as a property on child symbol.
;; when dictionary composed for a buffer, inherited dictionaries are
;; also looked up.
(defun emacspeak-pronounce-add-super (parent child)
  "Make CHILD inherit PARENT's pronunciations."
  (let ((orig (get child 'emacspeak-pronounce-supers)))
    (unless (memq parent orig)
      (setq orig
            (nconc orig (list parent)))
      (put child 'emacspeak-pronounce-supers orig))
    orig))

(defun emacspeak-pronounce-delete-super (parent child)
  "Stop child inheriting PARENT's pronunciations."
  (let ((orig (get child 'emacspeak-pronounce-supers)))
    (when (memq parent orig)
      (setq orig (delq parent orig))
      (put child 'emacspeak-pronounce-supers orig))
    orig))

(defun emacspeak-pronounce-compose-table (&optional buffer)
  "Compose  pronunciation table for BUFFER. "
  (setq buffer (or buffer (current-buffer)))
  (let* ((table (make-hash-table :test #'equal))
         (filename (buffer-file-name buffer))
         (directory (and filename (file-name-directory filename)))
         (mode
          (save-current-buffer
            (set-buffer buffer)
            major-mode))
         (mode-supers (emacspeak-pronounce-get-supers mode))
         (mode-parents (ems--mode-derive-chain mode))
         (file-alist
          (and filename (emacspeak-pronounce-get-dictionary filename)))
         (dir-alist
          (and directory (emacspeak-pronounce-get-dictionary directory)))
         (mode-alist (emacspeak-pronounce-get-dictionary mode))
         (super-alist nil)
         (parent-alist nil))
    (cl-loop
     for super in mode-supers do
     (setq super-alist (emacspeak-pronounce-get-dictionary super))
     (cl-loop for element in super-alist do
              (puthash (car element) (cdr element) table)))
    (cl-loop
     for parent in mode-parents do
     (setq parent-alist (emacspeak-pronounce-get-dictionary parent))
     (cl-loop for element in parent-alist do
              (puthash (car element) (cdr element) table)))
    (cl-loop
     for element in mode-alist do
     (puthash (car element) (cdr element) table))
    (cl-loop for element in dir-alist
             do
             (puthash (car element) (cdr element) table))
    (cl-loop
     for element in file-alist do
     (puthash (car element) (cdr element) table))
    table))

;;;  defining some inheritance relations:

;; c++ mode inherits from C mode
(emacspeak-pronounce-add-super 'c-mode 'c++-mode)

;; latex-mode and latex2e-mode inherit from plain-tex-mode

(emacspeak-pronounce-add-super 'plain-tex-mode 'latex-mode)
(emacspeak-pronounce-add-super 'plain-tex-mode 'latex2e-mode)
;; latex modes should inherit from plain text modes too
(emacspeak-pronounce-add-super 'text-mode 'latex-mode)
(emacspeak-pronounce-add-super 'text-mode 'latex2e-mode)
(emacspeak-pronounce-add-super 'text-mode 'plain-tex-mode)
;; xsl inherits from xml
(emacspeak-pronounce-add-super 'xml-mode 'xsl-mode)

;; VM,  EWW, org
(emacspeak-pronounce-add-super 'text-mode 'eww-mode)
(emacspeak-pronounce-add-super 'text-mode 'vm-presentation-mode)
(emacspeak-pronounce-add-super 'text-mode 'org-mode)

;;;  Composing and applying dictionaries:

;; Composing a dictionary results in the return of a hash table that
;; contains the applicable string.pronunciation pairs for a given
;; buffer.
;; Applying a pronunciation table results in the strings being
;; globally replaced by the defined pronunciations.
;; Case is handled similarly to vanila emacs behavior.

;;;  composing the dictionary

(defun emacspeak-pronounce-get-supers (child)
  "Return list of supers for mode `child'. "
  (get child 'emacspeak-pronounce-supers))

(defvar-local emacspeak-pronounce-personality nil
  "Personality used for pronunciations")

(defun emacspeak-pronounce-toggle-voice ()
  "Toggle use of pronunciation personality."
  (interactive )
  (cl-declare (special emacspeak-pronounce-personality))
  (cond
   (emacspeak-pronounce-personality
    (setq emacspeak-pronounce-personality nil))
   (t (setq emacspeak-pronounce-personality 'match)))
  (emacspeak-icon
   (if emacspeak-pronounce-personality 'on 'off))
  (message "Turned %s pronunciation personality"
           (if emacspeak-pronounce-personality 'on 'off)))

;;;  loading, clearing and saving dictionaries

(cl-declaim (special emacspeak-user-directory))

(defcustom emacspeak-pronounce-dictionaries-file
  (expand-file-name ".dictionary"
                    emacspeak-user-directory)
  "File that holds  emacspeak pronunciations."
  :type '(file :tag "Dictionary File ")
  :group 'emacspeak)

(defun emacspeak-pronounce-save-dictionaries ()
  "Saves  pronunciation dictionaries."
  (interactive)
  (cl-declare (special emacspeak-pronounce-dictionaries))
  (let* ((coding-system-for-write 'utf-8)
         (print-level nil)
         (print-length nil)
         (filename
          (read-file-name
           "Save pronunciation dictionaries to file: "
           emacspeak-user-directory
           nil nil
           (file-name-nondirectory emacspeak-pronounce-dictionaries-file)))
         (buffer nil))
    (setq buffer (find-file-noselect filename))
    (save-current-buffer
      (set-buffer buffer)
      (auto-fill-mode nil)
      (erase-buffer)
      (cl-loop for key being the hash-keys of emacspeak-pronounce-dictionaries
               do
               (insert
                (format "(emacspeak-pronounce-set-dictionary '%S\n '%S)\n"
                        key
                        (emacspeak-pronounce-get-dictionary key))))
      (save-buffer))))

(defvar emacspeak-pronounce-dictionaries-loaded nil
  "Indicates if dictionaries already loaded.")
(defun emacspeak-pronounce-load-dictionaries (&optional filename)
  "Load pronunciation dictionaries.
Optional argument FILENAME specifies the dictionary file,
Default is emacspeak-pronounce-dictionaries-file."
  (interactive
   (list
    (read-file-name
     "Load pronunciation dictionaries from file: "
     emacspeak-user-directory emacspeak-pronounce-dictionaries-file)))
  (cl-declare (special emacspeak-pronounce-dictionaries-file
                       emacspeak-pronounce-dictionaries-loaded))
  (setq filename (or  filename  emacspeak-pronounce-dictionaries-file))
  (when (file-exists-p filename)
    (condition-case nil
        (progn
          ;; `ems--fastload' is defined in `emacspeak-preamble' which requires
          ;; us, so we can't require it at top-level.
          (require 'emacspeak-preamble)
          (declare-function ems--fastload "emacspeak-preamble" (file))
          (ems--fastload filename)
          (setq emacspeak-pronounce-dictionaries-loaded t))
      (error (message "Error loading pronunciation dictionary")))))

(defun emacspeak-pronounce-clear ()
  "Clear all current pronunciation dictionaries."
  (interactive)
  (cl-declare (special emacspeak-pronounce-dictionaries))
  (when (yes-or-no-p
         "Do you really want to nuke all currently defined dictionaries?")
    (setq emacspeak-pronounce-dictionaries (make-hash-table))
    (emacspeak-pronounce-refresh-pronunciations)))

;;;  Front end to define pronunciations:

(defvar emacspeak-pronounce-keys
  '(("buffer" . "buffer")
    ("file" . "file")
    ("directory" . "directory")
    ("mode" . "mode"))
  "Pronunciations can be defined for these kinds of things.")

(defvar emacspeak-pronounce-current-buffer nil
  "Buffer name where we are currently defining a pronunciation.")

(defvar emacspeak-pronounce-yank-word-point nil
  "Point where we left off reading from the buffer containing the
  term being defined.")

(make-variable-buffer-local ' emacspeak-pronounce-yank-word-point)

(defun emacspeak-pronounce-read-term (key)
  (cl-declare (special emacspeak-pronounce-yank-word-point
                       emacspeak-pronounce-current-buffer))
  (let ((default (and (mark)
                      (< (count-lines (region-beginning)
                                      (region-end)) 2)
                      (buffer-substring-no-properties (region-beginning)
                                                      (region-end))))
        (emacspeak-pronounce-yank-word-point (point)))
    (setq emacspeak-pronounce-current-buffer (current-buffer))
    (read-from-minibuffer
     (format "Define pronunciation in %s for: " key)
     default
     (let ((now-map (copy-keymap minibuffer-local-map)))
       (progn
         (define-key now-map "\C-w"'emacspeak-pronounce-yank-word))
       now-map))))

(defun emacspeak-pronounce-get-key ()
  "Collect key from user.
Returns a pair of the form (key-type . key)."
  (cl-declare (special emacspeak-pronounce-keys))
  (let ((key nil)
        (key-type
         (read
          (completing-read
           "Define pronunciation that is specific to: "
           emacspeak-pronounce-keys nil t))))
    (when (called-interactively-p 'interactive) ;cleanup minibuffer history
      (pop minibuffer-history))
    (cond
     ((eq key-type 'buffer)
      (setq key (buffer-name))) ;handled differently
     ((eq key-type 'file)
      (setq key (buffer-file-name))
      (or key
          (error "Current buffer is not associated with a file"))
      (setq key (intern key)))
     ((eq key-type 'directory)
      (setq key
            (or
             (condition-case nil
                 (file-name-directory (buffer-file-name))
               (error nil))
             default-directory))
      (or key (error "No directory associated with current buffer"))
      (setq key (intern key)))
     ((eq key-type 'mode)
      (setq key major-mode)
      (or key (error "No major mode found for current buffer")))
     (t (error "Cannot define pronunciations with key type %s" key-type)))
    (cons key-type key)))

(defun emacspeak-pronounce-define-template-pronunciation ()
  "Interactively define template entries in the pronunciation dictionaries.
Default term to define is delimited by region.
First loads any persistent dictionaries if not already loaded."
  (interactive)
  (cl-declare (special emacspeak-pronounce-dictionaries-loaded))
  (let ((word nil)
        (pronunciation nil)
        (key-pair (emacspeak-pronounce-get-key)))
    (setq word (read-minibuffer "Pattern"))
    (setq pronunciation
          (cons
           (read-minibuffer
            (format "Matcher for %s: " word))
           (read-minibuffer
            (format "Pronouncer for %s: " word))))
    (when (and (not emacspeak-pronounce-dictionaries-loaded)
               (y-or-n-p
                "Load pre existing pronunciation dictionaries first? "))
      (emacspeak-pronounce-load-dictionaries))
    (unless (eq (car key-pair) 'buffer)
      (emacspeak-pronounce-add-dictionary-entry
       (cdr key-pair) word pronunciation)
      (emacspeak-pronounce-refresh-pronunciations))
    (when (eq (car key-pair) 'buffer)
      (emacspeak-pronounce-add-local-entry
       word pronunciation))))

(defun emacspeak-pronounce-define-pronunciation ()
  "Interactively define entries in the pronunciation dictionaries.
Default term to define is delimited by region.
First loads any persistent dictionaries if not already loaded."
  (interactive)
  (cl-declare (special emacspeak-pronounce-dictionaries-loaded))
  (let ((word nil)
        (pronunciation nil)
        (key-pair(emacspeak-pronounce-get-key)))
    (setq word (emacspeak-pronounce-read-term (cdr key-pair)))
    (setq pronunciation
          (read-from-minibuffer
           (format "Pronounce %s as: " word)))
    (when (and (not emacspeak-pronounce-dictionaries-loaded)
               (y-or-n-p
                "Load pre existing pronunciation dictionaries first? "))
      (emacspeak-pronounce-load-dictionaries))
    (unless (eq (car key-pair) 'buffer)
      (emacspeak-pronounce-add-dictionary-entry
       (cdr key-pair) word pronunciation)
      (emacspeak-pronounce-refresh-pronunciations))
    (when (eq (car key-pair) 'buffer)
      (emacspeak-pronounce-add-local-entry
       word pronunciation))))

;;;  Turning dictionaries on and off on a per buffer basis

(defvar-local  emacspeak-pronounce-table nil
  "AList for buffer pronunciations")

(defun  emacspeak-pronounce-table ()
  "Return the pronunciation table."
  emacspeak-pronounce-table)

(defun emacspeak-pronounce-toggle-dictionaries (&optional state)
  "Toggle  pronunciation dictionaries. "
  (interactive "P")
  (cl-declare (special emacspeak-pronounce-table))
  (unless state (setq state (not emacspeak-pronounce-table))) ; toggle
  (cond
   (state
    (setq emacspeak-pronounce-table (emacspeak-pronounce-compose-table)))
   ((null state) (setq emacspeak-pronounce-table nil)))
  (when (called-interactively-p 'interactive)
    (emacspeak-icon (if emacspeak-pronounce-table 'on 'off))
    (message "Pronunciations %s" (if emacspeak-pronounce-table "on" "off"))))

(defun emacspeak-pronounce-refresh-pronunciations ()
  "Refresh pronunciation table for current buffer. "
  (interactive)
  (cl-declare (special emacspeak-pronounce-table))
  (cond
   ((not (boundp 'emacspeak-pronounce-table)) ;first time
    (set (make-local-variable 'emacspeak-pronounce-table)
         (emacspeak-pronounce-compose-table)))
   (emacspeak-pronounce-table ;already on --refresh it
    (setq emacspeak-pronounce-table
          (emacspeak-pronounce-compose-table)))
   (t                                   ;turn it on
    (setq emacspeak-pronounce-table
          (emacspeak-pronounce-compose-table))))
  (when (called-interactively-p 'interactive)
    (emacspeak-icon 'on)
    (message
     "Refreshed pronunciations for this buffer")))

;;;  common dictionary containing smileys and friends

(defcustom emacspeak-pronounce-internet-smileys-pronunciations
  '((":-)" . " smile ")
    (";)" . " half-wink ")
    (":)" . " grin ")
    (":-(" . " frown ")
    (":(" . " sigh ")
    (":-I" . " shrug ")
    (":->" . " sarcastic smile ")
    (">:->" . " devillish smile ")
    (">;->" . " lewd smile ")
    (";-)" . " wink "))
  "Smileys"
  :link '(url-link :tag "Smileys Dictionary "
                   "http://oz.uc.edu/~solkode/smileys.html")
  :type '(repeat
          (cons :tag "Dictionary Entry"
                (string :tag "String")
                (string :tag "Pronunciation")))
  :group 'emacspeak)

;;;  xml namespace uri's

(defcustom emacspeak-pronounce-xml-ns
  '(
    ("http://www.w3.org/2005/Atom" . " atom ")
    ("http://www.w3.org/1999/02/22-rdf-syntax-ns#" . "RDF Syntax")
    ("http://www.w3.org/2002/06/xhtml2" . " xhtml2 ")
    ("http://www.w3.org/2003/XInclude" . "XInclude")
    ("http://www.w3.org/1999/XSL/Transform" . " XSLT ")
    ("http://www.w3.org/2002/xforms" . " XForms ")
    ("http://www.w3.org/2001/xml-events" . " XEvents ")
    ("http://www.w3.org/2001/vxml" . " vxml ")
    ("http://www.w3.org/2001/XMLSchema-instance". " XSI ")
    ("http://www.w3.org/2001/XMLSchema". " XSD ")
    ("http://www.w3.org/1999/xhtml" . " xhtml ")
    ("http://purl.org/dc/elements/1.1/" . "DC")
    ("http://search.yahoo.com/mrss/" . "media")
    )
  "Namespace URIs."
  :type '(repeat
          (cons :tag "Entry"
                (string :tag "URI")
                (string :tag "Pronunciation")))
  :group 'emacspeak)

;;;  adding predefined dictionaries to a mode:

(defun emacspeak-pronounce-augment (mode dictionary)
  "Augment pronunciations."
  (let ((mode-alist (emacspeak-pronounce-get-dictionary mode)))
    (cl-loop
     for e in dictionary do
     (unless (assoc (car e) mode-alist)
       (push e mode-alist)))
    (emacspeak-pronounce-set-dictionary mode mode-alist)))

;;;  dictionary editor

(defun emacspeak-pronounce-edit-generate-pronunciation-editor (key)
  "Edit dictionary for given key"
  (cl-declare (special emacspeak-pronounce-dictionaries))
  (unless emacspeak-pronounce-table
    (emacspeak-pronounce-toggle-dictionaries))
  (let ((value (gethash key emacspeak-pronounce-dictionaries))
        (notify (emacspeak-pronounce-edit-generate-callback key))
        (buffer (get-buffer-create (format "*Dict: %s" key)))
        (inhibit-read-only t))
    (with-current-buffer buffer
      (erase-buffer)
      (widget-insert (format "Dict: %s\n" key))
      (widget-create
       'repeat
       :help-echo "Edit" :tag "Edit"
       :value value :notify notify
       '(cons
         :tag "Entry"
         (string :tag "Phrase")
         (choice
          :tag "Pronounce"
          (string :tag "Phrase")
          (cons
           :tag "Pair"
           (symbol :tag "Matcher")
           (symbol :tag "Pronouncer")))))
      (widget-create
       'push-button
       :tag "Save"
       :notify
       #'(lambda (&rest _ignore)
           (call-interactively #'emacspeak-pronounce-save-dictionaries)))
      (use-local-map widget-keymap)
      (widget-setup)
      (goto-char (point-min)))
    (pop-to-buffer buffer)))

(defun emacspeak-pronounce-edit-generate-callback (field-name)
  "Generate a callback for use in the pronunciation editor widget."
  `(lambda (widget &rest ignore)
     (cl-declare (special emacspeak-pronounce-dictionaries))
     (let ((value (widget-value widget)))
       (setf
        (gethash
         (quote ,field-name)
         emacspeak-pronounce-dictionaries)
        value))))

(defun emacspeak-pronounce-edit-pronunciations (key)
  "Prompt for and launch a pronunciation editor on the
specified pronunciation dictionary key."
  (interactive
   (list
    (let ((keys
           (cl-loop for k being the hash-keys of
                    emacspeak-pronounce-dictionaries
                    collect
                    (symbol-name k))))
      (completing-read "Edit dictionary: "
                       (mapcar
                        #'(lambda (k)
                            (cons k k))
                        keys)
                       nil
                       'REQUIRE-MATCH
                       nil
                       'keys
                       (car keys)))))
  (cl-declare (special emacspeak-pronounce-dictionaries))
  (emacspeak-pronounce-edit-generate-pronunciation-editor
   (intern key)))

;;;  top level dispatch routine

(defvar emacspeak-pronounce-help
  "Dictionary: Clear Define Edit Load Refresh Save Toggle voicify"
  "Dictionary Help")

(defun emacspeak-pronounce-dispatch ()
  "Pronounce Frontend"
  (interactive)
  (cl-declare (special emacspeak-pronounce-help))
  (message emacspeak-pronounce-help)
  (let ((event (read-char)))
    (cl-case event
      (?c (call-interactively 'emacspeak-pronounce-clear))
      (?d (call-interactively
           'emacspeak-pronounce-define-pronunciation t))
      (?D (call-interactively
           'emacspeak-pronounce-define-template-pronunciation t))
      (?e (call-interactively
           'emacspeak-pronounce-edit-pronunciations t))
      (?l (call-interactively 'emacspeak-pronounce-load-dictionaries))
      (?r (call-interactively 'emacspeak-pronounce-refresh-pronunciations))
      (?s (call-interactively 'emacspeak-pronounce-save-dictionaries))
      (?t (call-interactively
           'emacspeak-pronounce-toggle-dictionaries))
      (?v (call-interactively 'emacspeak-pronounce-toggle-voice))
      (otherwise (message emacspeak-pronounce-help)))
    (emacspeak-icon 'close-object)))

;;;  Helpers: pronouncers

;;;  dates and numbers

(defvar emacspeak-pronounce-number-pattern
  "[0-9]+\\.?[0-9]+%?"
  "Pattern that matches  nnnn.nnnn")

;; Date: mm-dd-yyyy
(defvar emacspeak-pronounce-date-mm-dd-yyyy-pattern
  "[0-9]\\{2\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\([0-9]\\{2\\}\\)?"
  "Pattern that matches dates of the form mm-dd-[cc]yy.")

(declare-function calendar-date-string
                  "calendar" (date &optional abbreviate nodayname))

(defun emacspeak-pronounce-mm-dd-yyyy-date (string)
  "Return pronunciation for mm-dd-yyyy dates."
  (condition-case nil
      (let ((fields (mapcar #'read (split-string string "-"))))
        (calendar-date-string
         (list (cl-second fields)
               (cl-first fields)
               (cond
                ((< (cl-third fields) 50)
                 (+ 2000 (cl-third fields)))
                ((< (cl-third fields) 100)
                 (+ 1900 (cl-third fields)))
                (t (cl-third fields))))))
    (error string)))

;; Date: yyyy-mm-dd:

(defvar emacspeak-pronounce-date-yyyy-mm-dd-pattern
  "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}"
  "Pattern that matches dates of the form yy-mm-dd.")

(defun emacspeak-pronounce-yyyy-mm-dd-date (string)
  "Return pronunciation for yyyy-mm-dd  dates."
  (condition-case nil
      (let ((fields (mapcar #'read (split-string string "-"))))
        (calendar-date-string
         (list (cl-second fields)
               (cl-third fields)
               (cond
                ((< (cl-first fields) 50)
                 (+ 2000 (cl-first fields)))
                ((< (cl-first fields) 100)
                 (+ 1900 (cl-first fields)))
                (t (cl-first fields))))))
    (error string)))

(defvar emacspeak-pronounce-date-yyyymmdd-pattern
  "[0-9]\\{8\\}"
  "Pattern that matches dates of the form 20130101")

(defun emacspeak-pronounce-yyyymmdd-date (string)
  "Return pronunciation for yyyymmdd dates."
  (condition-case nil
      (calendar-date-string
       (list
        (read (substring string 4 6))
        (read (substring string 6))
        (read (substring string 0 4)))
       nil 'nodayname)
    (error string)))

;;;  phone numbers

(defvar emacspeak-pronounce-us-phone-number-pattern
  "1?-?[0-9]\\{3\\}-[0-9]\\{3\\}-[0-9]\\{4\\}"
  "Pattern that matches US phone numbers.")

(defun emacspeak-pronounce-us-phone-number (phone)
  "Return pronunciation for US phone number."
  (when (= 14 (length phone))
    (setq phone (substring phone 2)))
  (let ((area-code (substring phone 0 3))
        (prefix-code (substring phone 4 7))
        (suffix-code (substring phone 8 12)))
    (unless (string-equal "800" area-code)
      (setq area-code
            (replace-regexp-in-string
             "[0-9]" " \\&" area-code)))
    (setq prefix-code
          (replace-regexp-in-string
           "[0-9]" " \\&" prefix-code))
    (setq suffix-code
          (replace-regexp-in-string
           "[0-9]\\{2\\}" " \\&" suffix-code))
    (format "%s %s, %s. "
            area-code prefix-code suffix-code)))

(defvar emacspeak-pronounce-sha-checksum-pattern
  "[0-9a-f]\\{40\\}"
  "Regexp pattern that matches 40-digit SHA check-sum.")

(defun emacspeak-pronounce-sha-checksum (sha)
  "Return pronunciation for 40 digit SHA hash. Useful for working
with Git among other things."
  (when
      (and
       (= 40 (length sha))
       (string-match "[0-9a-f]+" sha))
    (format "sha: %s " (substring sha 0 6))))

(defvar emacspeak-pronounce-uuid-pattern
  (concat 
   "[0-9a-f]\\{8\\}" "-"
   "[0-9a-f]\\{4\\}" "-"
   "[0-9a-f]\\{4\\}" "-"
   "[0-9a-f]\\{4\\}" "-"
   "[0-9a-f]\\{12\\}")
  "Regexp pattern that matches hex-encoded, human-readable UUID.")

(defun emacspeak-pronounce-uuid (uuid)
  "Return pronunciation for human-readable UUID."
  (cl-declare (special emacspeak-pronounce-uuid-pattern))
  (when (and (= 36 (length uuid))
             (string-match emacspeak-pronounce-uuid-pattern uuid))
    (format "uid: %s..%s "
            (substring uuid 0 2)
            (substring uuid -2 nil))))

;;;  helper function --decode ISO date-time 

(defun ems-speak-rfc-3339-tz-offset (rfc-3339)
  "Return offset in seconds from UTC given an RFC-3339 time.
  Timezone spec is of the form -08:00 or +05:30 or [zZ] for UTC.
Value returned is compatible with `encode-time'."
  (cond
   ((string-match "[zZ]" (substring rfc-3339 -1))
    t)
   (t                                ;compute positive/negative offset
                                        ;in seconds
    (let ((fields
           (mapcar
            'read
            (split-string (substring rfc-3339 -5) ":"))))
      (*
       (if (string-match "-" (substring rfc-3339 -6))
           -60
         60)
       (+ (* 60 (cl-first fields))
          (cl-second fields)))))))

(defun emacspeak-speak-decode-rfc-3339-datetime (rfc-3339)
  "Return a speakable string description."
  (cl-declare (special emacspeak-speak-time-format))
  (let ((year (read (substring rfc-3339 0 4)))
        (month (read (substring rfc-3339 5 7)))
        (day (read (substring rfc-3339 8 10)))
        (hour (read (substring rfc-3339 11 13)))
        (minute (read (substring rfc-3339 14 16)))
        (second (read (substring rfc-3339 17 19)))
        (tz (ems-speak-rfc-3339-tz-offset rfc-3339)))
    ;; create the decoded date-time
    (condition-case nil
        (format-time-string emacspeak-speak-time-format
                            (encode-time second minute hour day month
                                         year tz))
      (error rfc-3339))))

(defvar emacspeak-pronounce-iso-datetime-pattern
  "[0-9]\\{8\\}\\(T[0-9]\\{6\\}\\)Z?"
  "Regexp pattern that matches ISO date-time.")

(defun emacspeak-pronounce-decode-iso-datetime (iso)
  "Return a speakable string description."
  (cl-declare (special emacspeak-speak-time-format))
  (let ((year (read (substring iso 0 4)))
        (month (read (substring iso 4 6)))
        (day (read (substring iso 6 8)))
        (hour 0)
        (minute 0)
        (second 0))
    (when (> (length iso) 12) ;; hour/minute
      (setq hour (read (substring iso 9 11)))
      (setq minute (read (substring iso 11 13))))
    (when (> (length iso) 14) ;; seconds
      (setq second (read (substring iso 13 15))))
    (when (and (> (length iso) 15) ;; utc specifier
               (char-equal ?Z (aref iso 15)))
      (setq second (+ (car (current-time-zone
                            (encode-time second minute hour day month
                                         year))) second)))
    ;; create the decoded date-time
    (condition-case nil
        (format-time-string emacspeak-speak-time-format
                            (encode-time second minute hour day month year))
      (error iso))))

;;;  helper function --decode rfc 3339 date-time

(defvar emacspeak-pronounce-rfc-3339-datetime-pattern
  (eval-when-compile
    (concat
     "[0-9]\\{4\\}-[0-9]\\{2\\}"
     "-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}\\(\\.[0-9]"
     "\\{3\\}\\)?\\([zZ]\\|\\([+-][0-9]\\{2\\}:[0-9]\\{2\\}\\)\\)"))
  "Regexp pattern that matches RFC 3339 date-time.")

(defun ems-pronounce-rfc-3339-tz-offset (rfc-3339)
  "Return offset in seconds from UTC given an RFC-3339 time.
  Timezone spec is of the form -08:00 or +05:30 or [zZ] for UTC.
Value returned is compatible with `encode-time'."
  (cond
   ((string-match "[zZ]" (substring rfc-3339 -1))
    t)
   (t                                ;compute positive/negative offset
                                        ;in seconds
    (let ((fields
           (mapcar
            'read
            (split-string (substring rfc-3339 -5) ":"))))
      (*
       (if (string-match "-" (substring rfc-3339 -6))
           -60
         60)
       (+ (* 60 (cl-first fields))
          (cl-second fields)))))))

(defun emacspeak-pronounce-decode-rfc-3339-datetime (rfc-3339)
  "Return a speakable string description."
  (cl-declare (special emacspeak-speak-time-format))
  (let ((year (read (substring rfc-3339 0 4)))
        (month (read (substring rfc-3339 5 7)))
        (day (read (substring rfc-3339 8 10)))
        (hour (read (substring rfc-3339 11 13)))
        (minute (read (substring rfc-3339 14 16)))
        (second (read (substring rfc-3339 17 19)))
        (tz (ems-pronounce-rfc-3339-tz-offset rfc-3339)))
    ;; create the decoded date-time
    (condition-case nil
        (format-time-string emacspeak-speak-time-format
                            (encode-time second minute hour day month
                                         year tz))
      (error rfc-3339))))

;;; Text Mode Pronunciations:
(emacspeak-pronounce-add-dictionary-entry
 'help-mode
 emacspeak-pronounce-sha-checksum-pattern
 (cons 're-search-forward
       'emacspeak-pronounce-sha-checksum))

(emacspeak-pronounce-add-dictionary-entry
 'text-mode
 (concat " -" emacspeak-pronounce-number-pattern)
 (cons
  #'re-search-forward
  #'(lambda (number)
      (concat " minus " (substring number 2)))))

;;; Merge  Dictionaries:

;; Over time, you can end up with dictionary entries in  a child-mode
;; e.g. eww-mode that better belong in the parent, e.g. text-mode.
;; Merging dictionaries results in entries from the source
;; dictionaries moving into the target dictionary. Once merged, these
;; entries  are removed from the source dictionary.
;; The same can happen when pronunciations are initially  defined for
;; a file,, then later merged into the  dictionary for  the
;; containing directory.

(defun emacspeak-pronounce-merge-dictionaries (from into)
  "Merge dic `from' into dict `into'"
  (interactive
   (let ((keys
          (cl-loop
           for k being  the hash-keys of
           emacspeak-pronounce-dictionaries collect k)))
     (list
      (read (completing-read "From:" keys))
      (read (completing-read "To:" keys)))))
  (cl-assert (not (eq from into)) t  "Same from and to dicts!")
  (let ((src (gethash from emacspeak-pronounce-dictionaries))
        (dst (gethash into emacspeak-pronounce-dictionaries)))
    (cl-loop
     for e in src do
     (cl-pushnew e dst :test #'equal))
    (puthash into dst emacspeak-pronounce-dictionaries )
    (puthash from nil emacspeak-pronounce-dictionaries )))

(provide 'emacspeak-pronounce)
;;;  emacs local variables

