(load-library "js-mode")
(load-library "moz")
(augment-auto-mode-alist  ".js$" 'js-mode)
(add-hook 'js-mode-hook 'moz-minor-mode)
(when
    (featurep 'folding)
  (fold-add-to-marks-list 'js-mode
                          "//<" "//>" ""))
                          
