;;; Customization lines to set up mime types.  -*- lexical-binding: t; -*-
;;; This is important to make sure tools like W3 render application/xhtml+xml
;;; rather than offering to download the file.
;;; The lines below are commented out
;;; you should be able to insert them   into your  .customize-emacs file if you use one.
;;; Alternatively, use these as a template when setting the values via custom.

;'(mm-text-html-renderer (quote w3))
;; '(mm-inlined-types (quote ("image/.*" "text/.*" "message/delivery-status" "message/rfc822" "message/partial" "message/external-body" "application/emacs-lisp" "application/x-emacs-lisp" "application/pgp-signature" "application/x-pkcs7-signature" "application/pkcs7-signature" "application/x-pkcs7-mime" "application/pkcs7-mime" "application/pgp" "application/xml" "application/xhtml+xml" "http://www.w3.org/1999/xhtml")))
;; '(mm-inline-media-tests (quote (("application/xml" mm-inline-text-html-render-with-w3 (lambda (&rest ignore) (or mm-text-html-renderer mm-text-html-renderer))) ("application/xhtml+xml" mm-inline-text-html-render-with-w3 (lambda (&rest ignore) (or mm-text-html-renderer mm-text-html-renderer))) ("image/p?jpeg" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote jpeg) handle))) ("image/png" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote png) handle))) ("image/gif" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote gif) handle))) ("image/tiff" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote tiff) handle))) ("image/xbm" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote xbm) handle))) ("image/x-xbitmap" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote xbm) handle))) ("image/xpm" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote xpm) handle))) ("image/x-xpixmap" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote xpm) handle))) ("image/bmp" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote bmp) handle))) ("image/x-portable-bitmap" mm-inline-image (lambda (handle) (mm-valid-and-fit-image-p (quote pbm) handle))) ("text/plain" mm-inline-text identity) ("text/enriched" mm-inline-text identity) ("text/richtext" mm-inline-text identity) ("text/x-patch" mm-display-patch-inline (lambda (handle) (fboundp (quote diff-mode)))) ("text/x-diff" mm-display-patch-inline (lambda (handle) (fboundp (quote diff-mode)))) ("application/emacs-lisp" mm-display-elisp-inline identity) ("application/x-emacs-lisp" mm-display-elisp-inline identity) ("application/x-shellscript" mm-display-shell-script-inline identity) ("application/x-sh" mm-display-shell-script-inline identity) ("text/x-sh" mm-display-shell-script-inline identity) ("text/dns" mm-display-dns-inline identity) ("text/x-org" mm-display-org-inline identity) ("text/html" mm-inline-text-html (lambda (handle) mm-text-html-renderer)) ("text/x-vcard" mm-inline-text-vcard (lambda (handle) (or (featurep (quote vcard)) (locate-library "vcard")))) ("message/delivery-status" mm-inline-text identity) ("message/rfc822" mm-inline-message identity) ("message/partial" mm-inline-partial identity) ("message/external-body" mm-inline-external-body identity) ("text/.*" mm-inline-text identity) ("audio/wav" mm-inline-audio (lambda (handle) (and (or (featurep (quote nas-sound)) (featurep (quote native-sound))) (device-sound-enabled-p)))) ("audio/au" mm-inline-audio (lambda (handle) (and (or (featurep (quote nas-sound)) (featurep (quote native-sound))) (device-sound-enabled-p)))) ("application/pgp-signature" ignore identity) ("application/x-pkcs7-signature" ignore identity) ("application/pkcs7-signature" ignore identity) ("application/x-pkcs7-mime" ignore identity) ("application/pkcs7-mime" ignore identity) ("multipart/alternative" ignore identity) ("multipart/mixed" ignore identity) ("multipart/related" ignore identity) ("audio/.*" ignore ignore) ("image/.*" ignore ignore) (".*" mm-inline-text mm-readable-p) ("application/pdf" emacspeak-wizards-pdf-open (lambda (&rest ignore) t)))))
