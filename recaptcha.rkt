#lang racket
(provide RECAPTCHA-SITEKEY RECAPTCHA-SECRET)
; Source: https://developers.google.com/recaptcha/docs/faq#id-like-to-run-automated-tests-with-recaptcha.-what-should-i-do
(define RECAPTCHA-SITEKEY "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI")
(define RECAPTCHA-SECRET "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe")
(module+ main)
