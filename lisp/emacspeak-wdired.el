;;; emacspeak-wdired.el --- Speech-enable wdired  -*- lexical-binding: t; -*-
;;
;; $Author: tv.raman.tv $
;; Description:  Emacspeak extension to speech-enable WDIRED
;; Keywords: Emacspeak, Multimedia
;;;   LCD Archive entry:

;; LCD Archive Entry:
;; emacspeak| T. V. Raman |tv.raman.tv@gmail.com
;; A speech interface to Emacs |
;; 
;;  $Revision: 4074 $ |
;; Location https://github.com/tvraman/emacspeak
;; 

;;;   Copyright:

;; Copyright (C) 1995 -- 2024, T. V. Raman
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

;;;   Introduction

;;; Commentary:
;; Speech-enable wdired to permit in-place renaming of groups of files.

;;; Code:
;;  required modules
(eval-when-compile (require 'cl-lib))
(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)

;;;  Advice interactive commands.

(cl-loop for c in
         '(wdired-next-line wdired-previous-line)
         do
         (eval
          `(defadvice ,c (after emacspeak pre act comp)
             "Speak."
             (when (ems-interactive-p)
               (emacspeak-icon 'select-object)
               (emacspeak-dired-speak-line)))))

(defadvice wdired-upcase-word (after emacspeak pre act comp)
  "Speak."
  (when (ems-interactive-p)
    (tts-with-punctuations 'some
                           (dtk-speak "upper cased file name. "))))
(defadvice wdired-capitalize-word (after emacspeak pre act comp)
  "Speak."
  (when (ems-interactive-p)
    (tts-with-punctuations 'some
                           (dtk-speak "Capitalized file name. "))))
(defadvice wdired-downcase-word (after emacspeak pre act comp)
  "Speak."
  (when (ems-interactive-p)
    (tts-with-punctuations 'some
                           (dtk-speak "Down cased file
  name. "))))

(defadvice wdired-toggle-bit (after emacspeak pre act comp)
  "Speak."
  (when (ems-interactive-p)
    (emacspeak-icon 'button)
    (dtk-speak "Toggled permission bit.")))

(defadvice wdired-abort-changes (after emacspeak pre act comp)
  "speak."
  (when (ems-interactive-p)
    (emacspeak-icon 'close-object)
    (tts-with-punctuations 'some
                           (dtk-speak "Cancelling  changes. "))))

(defadvice wdired-finish-edit (after emacspeak pre act comp)
  "speak."
  (when (ems-interactive-p)
    (emacspeak-icon 'save-object)
    (tts-with-punctuations 'some
                           (dtk-speak "Committed changes. "))))

(defadvice wdired-change-to-wdired-mode (after emacspeak pre act
                                               comp)
  "speak."
  (when (ems-interactive-p)
    (emacspeak-icon 'open-object)
    (tts-with-punctuations 'some
                           (dtk-speak "Entering writeable dir ed mode. "))))

(provide 'emacspeak-wdired)
;;;  end of file

