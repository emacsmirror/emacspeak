;;; emacspeak-nxml.el --- Speech enable nxml mode  -*- lexical-binding: t; -*-
;;
;; $Author: tv.raman.tv $
;; Description: XML Editor 
;; Keywords: Emacspeak, nxml streaming media 
;;;   LCD Archive entry: 

;; LCD Archive Entry:
;; emacspeak| T. V. Raman |tv.raman.tv@gmail.com 
;; A speech interface to Emacs |
;; 
;;  $Revision: 4532 $ | 
;; Location https://github.com/tvraman/emacspeak
;; 

;;;   Copyright:

;; Copyright (c) 1995 -- 2024, T. V. Raman
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

;;   Required modules:

(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)

:
;;; Commentary:
;; nxml-mode is a new XML mode for emacs by James Clark.
;;  Package nxml is available from the Emacs package archive.
;;; Code:

;;;  voice locking 
(voice-setup-add-map
 '(
   (nxml-attribute-colon voice-monotone-extra)
   (nxml-attribute-local-name voice-animate)
   (nxml-attribute-prefix voice-monotone-medium)
   (nxml-attribute-value-delimiter voice-smoothen)
   (nxml-attribute-value voice-lighten)
   (nxml-cdata-section-CDATA voice-animate-extra)
   (nxml-cdata-section-content  voice-monotone-extra)
   (nxml-cdata-section-delimiter voice-monotone-medium)
   (nxml-char-ref-delimiter voice-smoothen)
   (nxml-char-ref-number voice-animate-medium)
   (nxml-comment-content voice-monotone-extra)
   (nxml-comment-delimiter  voice-smoothen-medium)
   (nxml-delimited-data voice-animate-medium)
   (nxml-delimiter voice-bolden-medium)
   (nxml-element-colon voice-monotone-extra)
   (nxml-element-local-name voice-bolden)
   (nxml-element-prefix voice-monotone-medium)
   (nxml-entity-ref-delimiter voice-smoothen)
   (nxml-entity-ref-name  voice-lighten-medium)
   (nxml-hash  voice-monotone-extra)
   (nxml-markup-declaration-delimiter  voice-smoothen)
   (nxml-name  voice-animate-extra)
   (nxml-namespace-attribute-colon  voice-monotone-extra)
   (nxml-namespace-attribute-prefix  voice-animate)
   (nxml-namespace-attribute-value-delimiter  voice-smoothen)
   (nxml-namespace-attribute-value  voice-lighten)
   (nxml-namespace-attribute-xmlns  voice-smoothen-extra)
   (nxml-processing-instruction-content  voice-animate)
   (nxml-processing-instruction-delimiter  voice-lighten-extra)
   (nxml-processing-instruction-target  voice-animate-extra)
   (nxml-prolog-keyword  voice-animate-extra)
   (nxml-prolog-literal-content  voice-monotone-medium)
   (nxml-prolog-literal-delimiter  voice-monotone-extra)
   (nxml-ref  voice-animate-medium)
   (nxml-tag-delimiter  voice-smoothen)
   (nxml-tag-slash  voice-smoothen-medium)
   (rng-error  voice-bolden-and-animate)

   ;; the following are for emacs 23

   (nxml-attribute-colon voice-monotone-extra)
   (nxml-attribute-local-name voice-animate)
   (nxml-attribute-prefix voice-monotone-medium)
   (nxml-attribute-value-delimiter voice-smoothen)
   (nxml-attribute-value voice-lighten)
   (nxml-cdata-section-CDATA voice-animate-extra)
   (nxml-cdata-section-content  voice-monotone-extra)
   (nxml-cdata-section-delimiter voice-monotone-medium)
   (nxml-char-ref-delimiter voice-smoothen)
   (nxml-char-ref-number voice-animate-medium)
   (nxml-comment-content voice-monotone-extra)
   (nxml-comment-delimiter  voice-smoothen-medium)
   (nxml-delimited-data voice-animate-medium)
   (nxml-delimiter voice-bolden-medium)
   (nxml-element-colon voice-monotone-extra)
   (nxml-element-local-name voice-bolden)
   (nxml-element-prefix voice-monotone-medium)
   (nxml-entity-ref-delimiter voice-smoothen)
   (nxml-entity-ref-name voice-lighten-medium)
   (nxml-hash voice-monotone-extra)
   (nxml-markup-declaration-delimiter voice-smoothen)
   (nxml-name voice-animate-extra)
   (nxml-namespace-attribute-colon voice-monotone-extra)
   (nxml-namespace-attribute-prefix voice-animate)
   (nxml-namespace-attribute-value-delimiter voice-smoothen)
   (nxml-namespace-attribute-value voice-lighten)
   (nxml-namespace-attribute-xmlns voice-smoothen-extra)
   (nxml-processing-instruction-content voice-animate)
   (nxml-processing-instruction-delimiter voice-lighten-extra)
   (nxml-processing-instruction-target voice-animate-extra)
   (nxml-prolog-keyword voice-animate-extra)
   (nxml-prolog-literal-content voice-monotone-medium)
   (nxml-prolog-literal-delimiter voice-monotone-extra)
   (nxml-ref voice-animate-medium)
   (nxml-tag-delimiter voice-smoothen)
   (nxml-tag-slash voice-smoothen-medium)
   (rng-error voice-bolden-and-animate)))

;;;  pronunciations 
(cl-declaim (special
             emacspeak-pronounce-xml-ns))

;; nxml mode inherits from xml mode
(emacspeak-pronounce-augment
 'xml-mode
 emacspeak-pronounce-xml-ns)
(emacspeak-pronounce-add-super 'xml-mode 'nxml-mode)

;;;  Advice interactive commands

(defadvice nxml-electric-slash (around emacspeak pre act comp)
  "Speak."
  (cond
   ((ems-interactive-p)
    (let ((start (point)))
      ad-do-it
      (emacspeak-speak-region start (point))
      (when (= (preceding-char) ?>)
        (emacspeak-icon 'close-object))))
   (t ad-do-it))
  ad-return-value)

(defadvice nxml-complete (around emacspeak pre act comp)
  "Speak."
  (cond
   ((ems-interactive-p)
    (let ((start (point)))
      ad-do-it
      (emacspeak-speak-region start (point))))
   (t ad-do-it))
  ad-return-value)
(defadvice nxml-insert-xml-declaration (after emacspeak pre act
                                              comp)
  "Speak."
  (when (ems-interactive-p)
    (emacspeak-speak-line)))
(cl-loop for f in 
         '(nxml-backward-up-element
           nxml-forward-balanced-item
           nxml-up-element
           nxml-forward-paragraph
           nxml-backward-paragraph
           nxml-backward-single-paragraph
           nxml-backward-single-balanced-item
           nxml-forward-element
           nxml-backward-element)
         do
         (eval
          `(defadvice ,f (after emacspeak pre act comp)
             "speak."
             (when (ems-interactive-p)
               (emacspeak-icon 'large-movement)
               (emacspeak-speak-line)))))

(cl-loop for f in 
         '(nxml-balanced-close-start-tag-block
           nxml-finish-element
           nxml-balanced-close-start-tag-inline)
         do
         (eval
          `(defadvice ,f (after emacspeak pre act comp)
             "speak."
             (when (ems-interactive-p)
               (emacspeak-icon 'close-object)
               (dtk-speak
                (format "Closed %s"
                        (xmltok-start-tag-qname)))))))
;;;  speech enable outliner 

(cl-loop for f in
         '(nxml-hide-all-text-content 
           nxml-hide-direct-text-content 
           nxml-hide-other 
           nxml-hide-subheadings 
           nxml-hide-text-content)
         do
         (eval
          `(defadvice ,f (after emacspeak pre act comp)
             "Provide auditory icon."
             (when (ems-interactive-p)
               (emacspeak-icon 'close-object)
               (emacspeak-speak-line)))))

(cl-loop for f in
         '(nxml-show 
           nxml-show-all 
           nxml-show-direct-subheadings 
           nxml-show-direct-text-content 
           nxml-show-subheadings)
         do
         (eval
          `(defadvice ,f (after emacspeak pre act comp)
             "Provide auditory icon."
             (when (ems-interactive-p)
               (emacspeak-icon 'open-object)
               (emacspeak-speak-line)))))

;;;  Outline summarizer:

(defun emacspeak-nxml-summarize-outline ()
  "Intelligent spoken display of current outline entry."
  (interactive)
  (cl-declare (special o-close))
  (cond
   ((get-text-property (point) 'nxml-outline-state)
    (let ((o-open nil))
      (save-excursion
        (setq o-open (car (overlays-at (point))))
        (forward-line 1)
        (beginning-of-line)
        (forward-char -2)
        (setq o-close (car (overlays-at (point))))
        (dtk-speak (concat 
                    (overlay-get  o-open 'display)
                    (overlay-get o-close 'display)))))
    (emacspeak-icon 'ellipses))
   (t (message "Not on a hidden outline"))))

(provide 'emacspeak-nxml)
;;;  end of file 

