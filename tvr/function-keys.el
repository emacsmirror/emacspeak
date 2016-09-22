;; -*- lexical-binding: t; -*-

;(global-set-key '[f1] 'beginning-of-line)
;(global-set-key '[kp-f1] 'beginning-of-line)

(global-set-key '[f2]  'undefined)
;(global-set-key '[kp-f2]  'end-of-line)
(global-set-key '[f3] 'emacspeak-switch-to-previous-buffer)
(global-set-key '[f7] 'garbage-collect)
(global-set-key '[f4] 'emacspeak-kill-buffer-quietly)
(global-set-key '[kp-f4] 'emacspeak-kill-buffer-quietly)
(global-set-key [f5] 'bury-buffer)
(global-set-key '[find]  'yasb)
(global-set-key '[delete] 'dtk-toggle-punctuation-mode)
(global-set-key '[kp-enter] 'tmm-menubar)
(global-set-key  '[f8] 'emacspeak-remote-quick-connect-to-server)
(global-set-key '[f9] 'bbdb)
(global-set-key '[f10] 'eshell)
(global-set-key '[f11] 'shell)
(global-set-key '[f12] 'vm)
(define-key comint-mode-map [C-Return]
'emacspeak-speak-comint-send-input)
