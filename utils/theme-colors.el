;;; colors-theme.el -*- lexical-binding: t -*-
(require 'cl-lib)
(require 'name-this-color)

(defun tvr-theme-colors (palette)
  "Display colors in  palette"
  (interactive
   (list
    (intern
     (completing-read
      "Palette: "
      (cl-loop
       for s being the symbols when
       (and (boundp s)
            (not (functionp s))
            (string-match ".*palette$" (symbol-name s))) collect s)))))
  (with-current-buffer (get-buffer-create    "*Colors*")
    (insert (format "%s\n" palette))
    (cl-loop
     for p in  (symbol-value palette) 
     when (stringp (cl-second p)) do
     (let ((c (ems--color-name (cl-second p))))
       (set-text-properties 0 (length c) nil c)
       (insert (format "%s:\t%s\t%s\n" (cl-first p) c (cl-second p)))
       )))
  (with-current-buffer "*Colors*"
    (let ((inhibit-read-only  t))
      (save-excursion
        (goto-char (point-min))
        (while (search-forward (format  "%c" 34)) nil t (replace-match "" )))))
  (emacspeak-auditory-icon 'open-object)
  (funcall-interactively #'switch-to-buffer "*Colors*"))

(declare-function emacspeak-auditory-icon "emacspeak-sounds" (icon))
(declare-function ems--color-name "emacspeak-wizards" (color))


(provide 'theme-colors)
