;;; emacs/w3 has a CSS parser.  -*- lexical-binding: t; -*-
;;; It is presently bombing on my desktop machine Emacs/23
;;; but working at home and on my laptop in Emacs 24.
;;; The breakage is likely due to another installed emacs module.
;;; After failing to debug the breakage, I have decided to keep this file here:
;;; It was generated by a working instance of emacs/w3 under Emacs 24 and  it recreates  the parsed structure 
;;; that results from processing default.css in the W3 repostiroy.
;;; If you  suddenly find that your emacs/w3 renders the entire page as a single line of text with no styling, then load this file and all will be well again.

(puthash  'code '(((code . t) (richness . 8) (stress . 0) (pitch-range . 0) (pitch . 5) (white-space . pre) (white-space . pre))) w3-user-stylesheet)
(puthash  'h6 '(((h6 . t) (pitch-range . 4) (pitch . 6) (richness . 9) (stress . 2) (voice-family . paul) (color . [rgb 173 216 230]) (text-decoration underline) (font-weight . :bold) (font-family serif) (display . block))) w3-user-stylesheet)
(puthash  'h5 '(((h5 . t) (pitch-range . 5) (pitch . 5) (richness . 9) (stress . 2) (voice-family . paul) (color . [rgb 0 0 128]) (text-decoration underline) (font-weight . :bold) (font-family serif) (display . block))) w3-user-stylesheet)
(puthash  'h4 '(((h4 . t) (pitch-range . 6) (pitch . 4) (richness . 9) (stress . 2) (voice-family . paul) (color . [rgb 135 206 235]) (text-decoration underline) (font-weight . :bold) (font-family serif) (display . block))) w3-user-stylesheet)
(puthash  'h3 '(((h3 . t) (pitch-range . 7) (pitch . 3) (richness . 9) (stress . 2) (voice-family . paul) (color . [rgb 106 90 205]) (text-decoration underline) (font-weight . :bold) (font-family serif) (display . block))) w3-user-stylesheet)
(puthash  'h2 '(((h2 . t) (pitch-range . 8) (pitch . 2) (richness . 9) (stress . 2) (voice-family . paul) (color . [rgb 70 130 180]) (text-decoration underline) (font-weight . :bold) (font-family serif) (display . block))) w3-user-stylesheet)
(puthash  'h1 '(((h1 . t) (pitch-range . 9) (pitch . 1) (richness . 9) (stress . 2) (voice-family . paul) (color . [rgb 0 255 255]) (text-decoration underline) (font-weight . :bold) (font-family serif) (display . block))) w3-user-stylesheet)
(puthash  'em '(((em . t) (richness . 5) (stress . 6) (pitch-range . 6) (pitch . 6) (font-weight . :bold) (color . red))) w3-user-stylesheet)
(puthash  'strong '(((strong . t) (richness . 9) (stress . 9) (pitch-range . 6) (pitch . 6) (font-weight . :bold) (color . red))) w3-user-stylesheet)
(puthash  'dfn '(((dfn . t) (stress . 6) (pitch-range . 6) (pitch . 7) (font-style . italic) (font-style . italic))) w3-user-stylesheet)
(puthash  'strike '(((strike . t) (richness . 0) (text-decoration line-through) (color . green))) w3-user-stylesheet)
(puthash  's '(((s . t) (richness . 0) (text-decoration line-through) (color . green))) w3-user-stylesheet)
(puthash  'p '(((p . t) (display . block))) w3-user-stylesheet)
(puthash  'xmp '(((xmp . t) (richness . 8) (stress . 0) (pitch-range . 0) (pitch . 5) (white-space . pre) (display . block))) w3-user-stylesheet)
(puthash  'pre '(((pre . t) (richness . 8) (stress . 0) (pitch-range . 0) (pitch . 5) (white-space . pre) (display . block))) w3-user-stylesheet)
(puthash  'blockquote '(((blockquote . t) (display . block))) w3-user-stylesheet)
(puthash  'input '(((input :image) (text-decoration none)) ((input :button) (text-decoration none) (color . yellow)) ((input :reset) (text-decoration none) (color . red)) ((input :submit) (text-decoration none) (color . green)) ((input :int) (text-decoration underline)) ((input :float) (text-decoration underline)) ((input :url) (text-decoration underline)) ((input :password) (text-decoration underline)) ((input :text) (text-decoration underline) (text-decoration underline))) w3-user-stylesheet)
(puthash  'ul '((((ul . t) (ul . t)) (display . line)) (((ul . t) (ol . t)) (display . line)) ((ul . t) (list-style-type . circle) (display . block))) w3-user-stylesheet)
(puthash  'ol '((((ol . t) (ol . t)) (display . line)) (((ol . t) (ul . t)) (display . line)) ((ol . t) (list-style-type . decimal) (display . block))) w3-user-stylesheet)
(puthash  'dl '(((dl . t) (display . block))) w3-user-stylesheet)
(puthash  'dir '(((dir . t) (display . block))) w3-user-stylesheet)
(puthash  'menu '(((menu . t) (display . block))) w3-user-stylesheet)
(puthash  'dt '(((dt . t) (stress . 8) (richness . 6) (pitch . 6) (display . line) (font-weight . :bold))) w3-user-stylesheet)
(puthash  'dd '(((dd . t) (richness . 6) (pitch . 6) (margin-left . 26) (display . line))) w3-user-stylesheet)
(puthash  'li '(((li . t) (richness . 6) (pitch . 6) (margin-left . 26) (display . list-item))) w3-user-stylesheet)
(puthash  'div '(((div . t) (display . line))) w3-user-stylesheet)
(puthash  'sub '(((sub . t) (text-position . sub))) w3-user-stylesheet)
(puthash  'sup '(((sup . t) (text-position . sup))) w3-user-stylesheet)
(puthash  'secret '(((secret . t) (text-transform . rot13))) w3-user-stylesheet)
(puthash  'b '(((b . t) (richness . 9) (stress . 9) (pitch-range . 6) (pitch . 6) (font-weight . :bold))) w3-user-stylesheet)
(puthash  'i '(((i . t) (richness . 5) (stress . 6) (pitch-range . 6) (pitch . 6) (font-style . italic))) w3-user-stylesheet)
(puthash  'u '(((u . t) (richness . 0) (text-decoration underline))) w3-user-stylesheet)
(puthash  'blink '(((blink . t) (text-decoration blink))) w3-user-stylesheet)
(puthash  'center '(((center . t) (text-align . center) (display . line))) w3-user-stylesheet)
(puthash  'br '(((br . t) (display . line))) w3-user-stylesheet)
(puthash  'hr '(((hr . t) (text-align . center) (display . line))) w3-user-stylesheet)
(puthash  'a '(((a :active) (pitch . 8) (pitch-range . 8) (voice-family . betty) (color . [rgb 255 0 0])) ((a :visited) (voice-family . betty) (color . [rgb 178 34 34])) ((a :link) (voice-family . harry) (color . [rgb 255 0 0]))) w3-user-stylesheet)
(puthash  'table '(((table . t) (display . block))) w3-user-stylesheet)
(puthash  'th '(((th . t) (richness . 9) (stress . 9) (pitch-range . 6) (pitch . 6) (text-align . center) (font-weight . :bold) (display . block))) w3-user-stylesheet)
(puthash  'td '(((td . t) (text-align . left) (display . block))) w3-user-stylesheet)
(puthash  'caption '(((caption . t) (text-align . center) (display . block))) w3-user-stylesheet)
(puthash  'address '(((address . t) (display . line) (text-align . right))) w3-user-stylesheet)
(puthash  'abstract '(((abstract . t) (text-align . indent) (font-style . bold))) w3-user-stylesheet)
(puthash  'quote '(((quote . t) (text-align . indent) (font-style . italic))) w3-user-stylesheet)
(puthash  'tt '(((tt . t) (richness . 8) (stress . 0) (pitch-range . 0) (pitch . 5))) w3-user-stylesheet)
(puthash  'key '(((key . t) (richness . 8) (stress . 0) (pitch-range . 0) (pitch . 5))) w3-user-stylesheet)
(puthash  'plaintext '(((plaintext . t) (richness . 8) (stress . 0) (pitch-range . 0) (pitch . 5))) w3-user-stylesheet)
(puthash  'code '(((code . t) (richness . 8) (stress . 0) (pitch-range . 0) (pitch . 5) (white-space . pre) (white-space . pre))) w3-user-stylesheet)
