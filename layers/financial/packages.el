;;; packages.el --- financial layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: san <san@San-PC>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `financial-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `financial/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `financial/pre-init-PACKAGE' and/or
;;   `financial/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst financial-packages
  '()
  "The list of Lisp packages required by the financial layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")
(require 'request)
(require 'timer)

(defvar display-stock-timer nil)
(setq display-stock-default-load-average 1)
(setq var 0.01)
(setq display-stock-interval 1)
(defun display-stock-event-handler ()
  ;; (setq var (+ 0.01 var))
  ;; (setq s_var
  ;;       (concatenate 'string
  ;;                    (concatenate 'string
  ;;                                 "stock : "
  ;;                                 (number-to-string var))
  ;;                    "%% | "))
  (request
   "http://hq.sinajs.cn/"
   :params '(("list" . "sz000050"))
   :parser 'buffer-string
   :success
   (cl-function (lambda (&key data &allow-other-keys)
                  (when data
                    ;; (message data)
                    ;; (message (split-string data ","))
                    (setq s_var (nth 3 (split-string data ",")))
                    ;; (message s_var)
                    )))
   :error
   (cl-function (lambda (&key error-thrown &allow-other-keys&rest _)
                  (message "Got error: %S" error-thrown)))
   ;; :complete (lambda (&rest _) (message "Finished!"))
   :status-code '((400 . (lambda (&rest _) (message "Stock Got 400.")))
                  (418 . (lambda (&rest _) (message "Stock Got 418.")))))

  (setq display-stock-string (concatenate 'string " | s : " s_var))
  ;; (message s_var)
  (force-mode-line-update))

(define-minor-mode stock-mode
  :global t :group 'stock
  (and display-stock-timer (cancel-timer display-stock-timer))
  (setq display-stock-timer nil)
  (setq display-stock-string "")
  (or global-mode-string (setq global-mode-string '("")))
  (setq display-stock-load-average display-stock-default-load-average)
  (if stock-mode
      (progn
        (or (memq 'display-stock-string global-mode-string)
            (setq global-mode-string
                  (append global-mode-string '(display-stock-string))))
        ;; Set up the time timer.
        (setq display-stock-timer
              (run-at-time t display-stock-interval
                           'display-stock-event-handler))
        ;; Make the time appear right away.
        )))
;;; packages.el ends here
