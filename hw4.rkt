#lang racket

; Homework 4
; University of Victoria
; CSC 330 Fall 2018
; Prof. D.M. German
; Student: Alex L. Deweert
; ID: V00855767

; 0) cube an integer
(define (cube x)
  (* x x x))

; 1) sequence
(define (sequence low high stride)
  (if (> low high)
      null
      (cons low (sequence (+ low stride) high stride ))))

; 2) string-append-map
(define (string-append-map xs suffix)
  (map (lambda(x) (string-append x suffix)) xs))

; 3) list-nth-mod
(define (list-nth-mod xs n)
  (cond [ (< n 0) (error "list-nth-mod: negative number")]
        [ (eq? xs null) (error "list-nth-mod: empty list")]
        [ #t (list-ref xs (remainder n (length xs)))]))

; 4) stream-for-n-steps
(define (stream-for-n-steps stream n)
  ( letrec ([f (lambda (stream acc)
               ( if ( = n (length acc))
               (reverse acc)
               (f (cdr (stream)) (cons (car (stream)) acc ))))
             ])
    (f stream '() )))

; 5) funny-number-stream
(define funny-number-stream
  (
   letrec(
          [ f (lambda(x)
                (cons x
                      (lambda() (f (if (= 0 (remainder (+ x 1) 5))
                                   ;then
                                   (* -1 (+ x 1))
                                   ;else
                                   ( if (< (+ x 1) 0)
                                     ;then
                                     (* -1 (- x 1))
                                     ;else
                                     (+ x 1 )))
                                 ))))])
          (lambda() (f 1))))

; 6) cat-then-dog
(define cat-then-dog (
   letrec( [ f (lambda(x) (cons x (lambda() (f (if (string=? x "cat.jpg") "dog.jpg" "cat.jpg" )))  )  )])
   (lambda() (f "cat.jpg"))
  )
)

; 7) stream-add-zero
(define (stream-add-zero s) (letrec
           ([f (lambda(sprime)
              (cons (cons 0 (car (sprime)))
                    (lambda() (f (cdr (sprime)))))
           )])
  (lambda() (f s))))

; 8) cycle-lists
(define (cycle-lists xs ys)
  (letrec ([aux (lambda(n) (cons
                             (cons (list-ref xs (modulo n (length xs))) (list-ref ys (modulo n (length ys))))
                             (lambda() (aux(+ n 1)))
                           )
           )])
           (lambda() (aux 0))
  )
)

; 9) vector-assoc
(define (vector-assoc val vec)
  ( letrec [(f (lambda(n)
                 ;iterate through list until n = 0
                 ;if n == 0 were at the end with no match
                 (if (= n 0)
                     ;then return false
                     #f
                     ;else
                           ;is the vector element a pair?
                     (cond [ (pair? (vector-ref vec (- n 1)))
                                         (if ( = val (car (vector-ref vec (- n 1))))
                                            ;return the pair assoc with the val
                                            (vector-ref vec (- n 1))
                                            ;else call f again with n-1
                                            (f(- n 1) ))]
                           ;else its not a pair, continue on next iteration
                           [#t (f(- n 1) )]
                      )
                  )))]
     (f (vector-length vec))
  )
)

; 10) cached-assoc
; the returned function returns the same thing as (assoc v xs)
; but we're optimizing the behavior of returned f to use a cache vector
(define (cached-assoc xs n)
  ;define the cache which is a vector size n
  (letrec [ (cache (make-vector n #f))
            (cache-count 0) ]
          
  ;init the vector with #f
  ;return a function that behaves the same way (assoc v xs) does but called like (assoc v) using existing xs in the cached-assoc environment
  ;when the return function is called, check cache to see if the element v exists in cache, if yes, return it, if no return false
  (lambda(v) 
              ;first check cache for existence of v (iterate through cache looking for any pair with (car x) == v
              (let [(cache-result (vector-assoc v cache))]
                ;if v is in the car of a pair in cache return the pair
                (cond
                  [ (pair? cache-result) cache-result ]
                  ;[ (pair? cache-result) (begin (print "cached result: ") cache-result) ]
                  [ (not(pair? cache-result))
                      ;does both (the cond operator executes all in [...] if the check is true
                      (let [(assoc-result (assoc v xs))] (if (pair? assoc-result)
                                         ;if the call to assoc is pair, then store in cache (round robin)
                                         ;places new value at cache location cache-count % n, updates cache count, returns result
                                         (begin (vector-set! cache (modulo cache-count n) assoc-result) (set! cache-count (+ cache-count 1)) assoc-result)
                                         ;else return false
                                         #f ))])))))

; 11) while-less
(define-syntax while-less
  (syntax-rules (do) [ (while-less e1 do e2)
                       (letrec [ (f (lambda(current-e2)   
                                   (cond[ (< current-e2 e1) (f e2) ]
                                        [#t])
                                ))]
   (f e2))]))

(provide sequence)
(provide string-append-map)
(provide list-nth-mod)
(provide stream-for-n-steps)
(provide funny-number-stream)
(provide cat-then-dog)
(provide stream-add-zero)
(provide cycle-lists)
(provide vector-assoc)
(provide cached-assoc)
(provide while-less)