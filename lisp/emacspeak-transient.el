;;; emacspeak-transient.el --- TRANSIENT  -*- lexical-binding: t; -*-
;; $Author: tv.raman.tv $
;; Description:  Speech-enable TRANSIENT An Emacs Interface to transient
;; Keywords: Emacspeak,  Audio Desktop transient
;;;   LCD Archive entry:

;; LCD Archive Entry:
;; emacspeak| T. V. Raman |tv.raman.tv@gmail.com
;; A speech interface to Emacs |
;; 
;;  $Revision: 4532 $ |
;; Location https://github.com/tvraman/emacspeak
;; 

;;;   Copyright:

;; Copyright (C) 1995 -- 2007, 2011, T. V. Raman
;; Copyright (c) 1994, 1995 by Digital Equipment Corporation.
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
;; MERCHANTABILITY or FITNTRANSIENT FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Commentary:
;; TRANSIENT ==  Transient commands --- used by magit and friends.
;; This module speech-enables transient.

;; @subsection Introduction
;; 
;; Package Transient is similar to package Hydra in the sense that it
;; can be used to create a sequence of chained/hierarchical commands
;; that are invoked via a sequence of keys. It is used by Magit for
;; dispatching to the various Git commands.  Speech-enabling package
;; Transient results in the various interactive commands producing
;; auditory feedback. Transient shows an ephemeral window with the
;; currently available commands, Emacspeak speech-enables
;; transient--show to cache that content so it can be browsed if
;; desired.
;; 
;; Finally, this module defines a new minor mode called
;; transient-emacspeak  that  enables  interactive browsing of the
;; contents displayed temporarily. Note that without this
;; functionality, learning complex packages like Magit would be difficult
;; because  the list of available commands can be very long.
;; @subsection Recommended Customizations
;; I use the following customizations via .custom, adjust to taste,
;; but use these only after reading the transient info documentations.
;; @itemize
;; @item transient-force-single-column: t
;; @item  transient-show-popup:  1
;; @item transient-enable-popup-navigation:  t
;; @end itemize
;; 
;; this pops up the transient buffer after a short delay  and lets
;; you move through the buttons with the    up/down arrows. 
;; @subsection Browsing Contents Of transient--show
;; 
;; When executing a command defined via Transient --- e.g. command
;; Magit-dispatch and friends, press @kbd {C-z} (transient-suspend) to
;; temporarily suspend   the currently active transient. Emacspeak now
;; displays a  *transient-emacspeak* buffer that displays the contents of the
;; most recently displayed transient choices. Pressing @kbd {r} resumes
;; the transient; Pressing @kbd{C-q} quits the transient.
;; 
;;; Code:

;;   Required modules:

(eval-when-compile (require 'cl-lib))
(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)
(require 'derived)
(eval-when-compile (require 'transient))

;;; Map Faces:

(voice-setup-add-map
 '(
   (transient-active-infix voice-animate)
   (transient-amaranth voice-animate)
   (transient-argument voice-animate)
   (transient-blue voice-lighten)
   (transient-disabled-suffix inaudible)
   (transient-enabled-suffix voice-brighten)
   (transient-heading voice-lighten)
   (transient-higher-level voice-brighten)
   (transient-inactive-argument inaudible)
   (transient-inactive-value inaudible)
   (transient-key voice-animate)
   (transient-mismatched-key voice-monotone-extra)
   (transient-nonstandard-key voice-monotone-extra)
   (transient-pink voice-bolden-medium)
   (transient-red voice-bolden)
   (transient-separator  'inaudible)
   (transient-teal voice-lighten-medium)
   (transient-unreachable voice-monotone-extra)
   (transient-unreachable-key voice-monotone-extra)
   (transient-value voice-brighten)
   ))

;;;  Advice Interactive Commands:

(defadvice transient-toggle-common (after emacspeak pre act comp)
  "speak."
  (cl-declare (special transient-show-common-commands))
  (when (ems-interactive-p)
    (dtk-stop 'all)
    (emacspeak-icon
     (if transient-show-common-commands 'on 'off))))

(defadvice transient-resume (after emacspeak pre act comp)
  "speak."
  (when (ems-interactive-p)
    (dtk-stop 'all)
    (emacspeak-icon 'open-object)))

(cl-loop
 for f in
 '(transient-quit-all transient-quit-one transient-quit-seq )
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "speak."
     (when (ems-interactive-p)
       (dtk-stop 'all)
       (emacspeak-icon 'close-object)
       (when (eq major-mode 'emacspeak-transient-mode) (bury-buffer))
       (emacspeak-speak-mode-line)))))

(cl-loop
 for f in
 '(transient-save transient-set)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "speak."
     (when (ems-interactive-p)
       (emacspeak-icon 'save-object)
       (dtk-stop 'all)))))

(cl-loop
 for f in
 '(transient-history-next transient-history-prev)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "speak."
     (when (ems-interactive-p)
       (dtk-speak-list (minibuffer-contents))
       (emacspeak-icon 'select-object)))))

(define-derived-mode emacspeak-transient-mode special-mode
  "Browse current transient choices"
  "emacspeak integration with Transient."
  (cl-declare (special transient-sticky-map))
  (use-local-map transient-sticky-map)
  (local-set-key (kbd "M-n") 'emacspeak-transient-next-section)
  (local-set-key (kbd "M-p") 'emacspeak-transient-previous-section)
  (local-set-key "q" 'bury-buffer)
  (local-set-key "r" 'transient-resume))

(defvar emacspeak-transient-cache nil
  "Cache of the last Transient buffer contents.")

(defadvice transient--show (after emacspeak pre act comp)
  "Speak and set up cache."
  (when (window-live-p transient--window)
    (with-current-buffer (window-buffer transient--window)
      (setq emacspeak-transient-cache
            (buffer-substring (point-min)  (point-max)))
      (emacspeak-speak-line)
      (emacspeak-icon 'open-object))))

(defadvice transient-suspend (around emacspeak pre act comp)
  "Pop to *Transient-emacspeak* buffer where the message emitted by
the transient can be browsed.
Press `r' to resume the suspended transient."
  (cl-declare (special emacspeak-transient-cache))
  (cond
   ((ems-interactive-p)
    (let ((buff (get-buffer-create "*Transient-Emacspeak*"))
          (inhibit-read-only t))
      ad-do-it
      (emacspeak-icon 'close-object)
      (with-current-buffer buff
        (erase-buffer)
        (insert "r to resume, C-g to quit.\n\n")
        (insert emacspeak-transient-cache)
        (goto-char (point-min))
        (emacspeak-transient-mode))
      (switch-to-buffer buff)
      (emacspeak-speak-mode-line)))
   (t ad-do-it))
  ad-return-value)

;;; section nav:

(defun emacspeak-transient-next-section ()
  "Next transient section."
  (interactive)
  (with-selected-window
      (if (window-live-p transient--window)
          transient--window (selected-window))
    (when-let
        ((match
          (text-property-search-forward 'face 'transient-heading t t)))
      (goto-char (prop-match-beginning match))
      (emacspeak-speak-region (point) (prop-match-end match)))))

(defun emacspeak-transient-previous-section ()
  "Previous transient section."
  (interactive)
  (with-selected-window
      (if (window-live-p transient--window)
          transient--window (selected-window))
    (when-let
        ((match
          (text-property-search-backward
           'face 'transient-heading t t)))
      (goto-char (prop-match-beginning match))
      (emacspeak-speak-region (point) (prop-match-end match)))))

;;; Hooks:

(defun emacspeak-transient-post-hook ()
  "Actions to execute after transient is done."
  (cl-declare (special transient--stack))
  (unless transient--stack
    (dtk-stop 'all)
    (emacspeak-icon 'task-done)
    (emacspeak-speak-mode-line)))

(add-hook 'transient-exit-hook 'emacspeak-transient-post-hook)

;;; Advice transient navigation:
(cl-loop
 for f in
 '(transient-backward-button transient-forward-button)
 do
 (eval
  `(defadvice ,f (around emacspeak pre act comp)
     "speak selected button"
     (cond
      ((ems-interactive-p)
       ad-do-it
       (with-current-buffer (window-buffer transient--window)
         (when-let ((button (button-at (point)))
                    (start (button-start button))
                    (end (button-end button)))
           (dtk-speak (buffer-substring start end))
           (emacspeak-icon 'button))))
      (t ad-do-it))
     ad-return-value)))

;;; Enable And Customize Transient Navigation:
(declare-function transient-push-button "emacspeak-transient" t)

(defun emacspeak-transient-setup ()
  "Emacspeak Transient Customizations"
  (cl-declare (special transient-enable-popup-navigation
                       transient-popup-navigation-map
                       transient-predicate-map))
  (keymap-set  transient-popup-navigation-map "C-j" #'transient-push-button)
  (define-key transient-predicate-map
              [emacspeak-transient-previous-section] 'transient--do-move)
  (define-key transient-predicate-map
              [emacspeak-transient-next-section] 'transient--do-move)

  (define-key transient-popup-navigation-map "C-j" 'transient-push-button)
  (define-key transient-popup-navigation-map
              [left] 'emacspeak-transient-previous-section)
  (define-key transient-popup-navigation-map
              [right] 'emacspeak-transient-next-section)

  (setq transient-enable-popup-navigation t
        transient-force-single-column t
        transient-semantic-coloring t
        transient-show-popup 1))
(emacspeak-transient-setup)

(provide 'emacspeak-transient)
;;;  end of file

