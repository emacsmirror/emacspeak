;;; emacspeak-eudc.el --- Speech enable  LDAP -*- lexical-binding: t; -*- 
;;
;; $Author: tv.raman.tv $
;; Description:   extension to speech enable universal directory client 
;; Keywords: Emacspeak, Audio Desktop
;;;   LCD Archive entry:

;; LCD Archive Entry:
;; emacspeak| T. V. Raman |tv.raman.tv@gmail.com
;; A speech interface to Emacs |
;; 
;;  $Revision: 4532 $ |
;; Location https://github.com/tvraman/emacspeak
;; 

;;;   Copyright:

;; Copyright (C) 1995 -- 2024, T. V. Raman<tv.raman.tv@gmail.com>
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
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;  required modules
(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)
(require 'widget)
(require 'emacspeak-widget)
(declare-function widget-at "wid-edit" (&optional pos))
(declare-function widget-type "wid-edit" (widget))

;;; Commentary:

;; EUDC --Emacs Universal Directory Client 
;; provides a unified interface to directory servers
;; e.g. ldap servers
;; this module speech enables eudc 

;;; Code:

;;;  speech enable interactive commands 

(defadvice eudc-move-to-next-record (after emacspeak pre act comp)
  "speak. "
  (when (ems-interactive-p)
    (emacspeak-icon 'select-object)
    (emacspeak-speak-line)))

(defadvice eudc-move-to-previous-record (after emacspeak pre act
                                               comp)
  "speak. "
  (when (ems-interactive-p)
    (emacspeak-icon 'select-object)
    (emacspeak-speak-line)))

;;;  speech enable  eudc widgets 

(defun emacspeak-eudc-widget-help (widget)
  "Provides emacspeak help for eudc widgets. "
  (cond
   ((eq (widget-type widget) 'editable-field)
    (concat (ems--this-line) "Edit "))
   ((eq (widget-type widget) 'push-button)
    (concat "Push button "
            (widget-value widget)))
   (t (emacspeak-widget-default-summarize widget))))

(defun emacspeak-eudc-widgets-add-emacspeak-help ()
  "Adds emacspeak widget help to all EUDC widgets. "
  (save-excursion 
    (goto-char (point-min))
    (while  (not (eobp))
      (goto-char (next-overlay-change (point)))
      (when (widget-at (point))
        (widget-put (widget-at (point))
                    :emacspeak-help 
                    'emacspeak-eudc-widget-help)
        (forward-line 1)))))

(defadvice eudc-query-form (after emacspeak pre act comp)
  "Attach emacspeak help to all EUDC widgets.
Summarize the form to welcome the user. "
  (cl-declare (special eudc-server))
  (emacspeak-eudc-widgets-add-emacspeak-help)
  (emacspeak-icon 'open-object)
  (let((server (propertize "Server " 'personality voice-smoothen))
       (host eudc-server))
    (dtk-speak 
     (concat server 
             " " 
             host 
             " " 
             (when (widget-at (point))
               (emacspeak-eudc-widget-help (widget-at (point))))))))

;;;  additional interactive commands 

(defun emacspeak-eudc-send-mail ()
  "Send email to the address given by the current record. "
  (interactive)
  (unless (eq major-mode  'eudc-mode)
    (error "This command should be called in EUDC buffers. "))
  (let ((record
         (overlay-get (car (overlays-at (point))) 'eudc-record))
        (mail nil))
    (unless record (error "Not on a record. "))
    (setq mail
          (cdr (assq 'mail record)))
    (if mail
        (sendmail-user-agent-compose mail)
      (error "Cannot determine email address from record %s"
             (cdr (assq 'mail record))))))

;;;  bind additional commands 

(cl-declaim (special eudc-mode-map))
(when (boundp 'eudc-mode-map)
  (define-key eudc-mode-map "m" 'emacspeak-eudc-send-mail)
  )

;;;  voiceify values in results 

(defvar emacspeak-eudc-attribute-value-personality
  voice-animate
  "Personality t use for voiceifying attribute values. ")

(defadvice eudc-print-attribute-value (around emacspeak pre
                                              act comp)
  "voiceify attribute values"
  (cond
   ((not emacspeak-eudc-attribute-value-personality)
    ad-do-it)
   (t (let ((start (point)))
        ad-do-it
        (with-silent-modifications
          (put-text-property start (point)
                             'personality
                             emacspeak-eudc-attribute-value-personality)))))
  ad-return-value)

(provide 'emacspeak-eudc)
;;;  end of file

