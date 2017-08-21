;; -*- lexical-binding: t; -*-

(augment-load-path "twittering-mode" "twittering-mode")
(autoload 'twit "twittering-mode" t)
(eval-after-load 'twit
`(progn
   (require 'epa)
(setq twittering-use-master-password t)
(setq epa-protocol 'OpenPGP)
(setq twittering-timer-interval 300)
(setq twittering-timer-interval-for-redisplaying 300)
(setq twittering-initial-timeline-spec-string
              '("(:home+@)"
                ;"(:search/tvraamn/+:search/chromevox/+:search/emacspeak/+:search/googleaccess/)"
                ))
(setq twittering-number-of-tweets-on-retrieval 50)
(setq twittering-edit-skeleton 'inherit-any)
))
