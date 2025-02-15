#lang racket
(require redis)
(require "banned.rkt")
(provide contains-banned? contains-pat?)

;; delete all non-hash vals (ie, not pastes)
(define (delete-nonpastes #:trial? [trial? #f])
  (for ([k (KEYS "*")])
    ; delete non-hashes
    (unless (string=? (TYPE k) "hash")
      (printf "deleting non-hash key: ~a\n" k)
      (unless trial? (DEL k)))
    ; delete hashes that are not pastes
    (unless (HEXISTS k 'code)
      (printf "deleting non-paste hash key: ~a\n" k)
      (unless trial? (DEL k)))))

(define (contains-banned? str)
  (for/or ([p default-pats])
    (contains-pat? p str)))
(define (contains-pat? pat str)
  (define ci-pat (pregexp (string-append "(?i:" pat ")")))
  (regexp-match ci-pat str))

; deletes pastes satisfying the given regexp pattern
(define (delete-pastes/pat pat #:trial? [trial? #f])
  (define count 0)
  (printf "searching for pastes with pattern: ~a" pat)
  (when trial? (printf " (trial)"))
  (printf "\n")
  (for ([k (KEYS "*")])
    (when (and (string=? (TYPE k) "hash") (HEXISTS k 'code)) ; valid paste
      (define paste-contents (HGET/str k 'code))
      (define paste-name (HGET/str k 'name))
      (define paste-dir (build-path "tmp" (bytes->path k)))
      (when (or (contains-pat? pat paste-contents)
                (contains-pat? pat paste-name))
        (printf "deleting paste: ~a\n" k)
        (when (directory-exists? paste-dir)
          (printf "... and deleting directory: ~a\n" paste-dir))
        (unless trial?
          ;; log the deletion
          (with-output-to-file (build-path "deleted-pastes" (bytes->path k))
            (lambda ()
              (printf "time: ~a\n" (HGET/str k 'time))
              (printf "name: ~a\n" (HGET/str k 'name))
              (printf "num: ~a\n" k)
              (printf "~a\n" paste-contents)))
          ;; do the deletion
          (DEL k)
          (when (directory-exists? paste-dir)
            (delete-directory/files paste-dir)))
        (set! count (add1 count)))))
  (printf "deleted ~a pastes matching pattern ~a\n" count pat))

(module+ main
  (define trial-mode (make-parameter #t))
  (define pats
    (command-line
     #:once-each
     [("--delete") "Do the deletions (default is trial mode)"
      (trial-mode #f)]
     #:args args
     (if (null? args) default-pats args)))
  (for ([p pats])
    (delete-pastes/pat p #:trial? (trial-mode))))
