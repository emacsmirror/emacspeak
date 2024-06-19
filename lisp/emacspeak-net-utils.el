;;; emacspeak-net-utils.el --- net-utils  -*- lexical-binding: t; -*-
;;
;; $Author: tv.raman.tv $ 
;; Description:  Emacspeak extension to speech enable net-utils
;; Keywords: Emacspeak, network utilities 
;;;   LCD Archive entry: 

;; LCD Archive Entry:
;; emacspeak| T. V. Raman |tv.raman.tv@gmail.com 
;; A speech interface to Emacs |
;; 
;;  $Revision: 4532 $ | 
;; Location https://github.com/tvraman/emacspeak
;; 

;;;   Copyright:
;; Copyright (C) 1995 -- 2024, T. V. Raman 
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
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Commentary:

;; This module speech enables net-utils
;;; Code:
;;;  requires
(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)

;;;  advice

(cl-loop
 for f in
 '(
   arp route traceroute
   ifconfig iwconfig ping netstat
   dns-lookup-host nslookup-host)
 do
 (eval
  `(defadvice ,f  (after emacspeak pre act comp)
     "Speak output"
     (when (ems-interactive-p)
       (emacspeak-icon 'open-object)
       (message "Displayed results of %s in other window"
                (quote ,f))))))

(provide 'emacspeak-net-utils)

;;;  end of file 

