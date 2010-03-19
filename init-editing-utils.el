;;----------------------------------------------------------------------------
;; Overwrite text when the selection is active
;;----------------------------------------------------------------------------
(delete-selection-mode 1)


;;----------------------------------------------------------------------------
;; Show and edit all lines matching a regex
;;----------------------------------------------------------------------------
(require 'all)


;;----------------------------------------------------------------------------
;; Don't disable case-change functions
;;----------------------------------------------------------------------------
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)


;;----------------------------------------------------------------------------
;; Rectangle selections
;;----------------------------------------------------------------------------
(setq cua-enable-cua-keys nil) ;; only for rectangles, with C-RET
(cua-mode t)


;;----------------------------------------------------------------------------
;; Conversion of line endings
;;----------------------------------------------------------------------------
;; Can also use "C-x ENTER f dos" / "C-x ENTER f unix" (set-buffer-file-coding-system)
(require 'eol-conversion)


;;----------------------------------------------------------------------------
;; Handy key bindings
;;----------------------------------------------------------------------------
;; To be able to M-x without meta
(global-set-key (kbd "C-x C-m") 'execute-extended-command)

(global-set-key (kbd "C-c j") 'join-line)
(global-set-key (kbd "C-c J") (lambda () (interactive) (join-line 1)))
(global-set-key (kbd "M-T") 'transpose-lines)

(defun duplicate-line ()
  (interactive)
  (save-excursion
    (let ((line-text (buffer-substring-no-properties
                      (line-beginning-position)
                      (line-end-position))))
      (move-end-of-line 1)
      (newline)
      (insert line-text))))

(global-set-key (kbd "C-c p") 'duplicate-line)

;; Train myself to use M-f and M-b instead
(global-unset-key [M-left])
(global-unset-key [M-right])


;;----------------------------------------------------------------------------
;; Shift lines up and down
;;----------------------------------------------------------------------------
(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg))
        (forward-line -1))
      (move-to-column column t)))))

(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))


(global-set-key [M-S-up] 'move-text-up)
(global-set-key [M-S-down] 'move-text-down)



;;----------------------------------------------------------------------------
;; Cut/copy the current line if no region is active
;;----------------------------------------------------------------------------
(defadvice kill-ring-save (before slick-copy activate compile) "When called
  interactively with no active region, copy a single line instead."
  (interactive (if mark-active (list (region-beginning) (region-end))
                 (message "Copied line")
                 (list (line-beginning-position)
                       (line-beginning-position 2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
    (if mark-active (list (region-beginning) (region-end))
      (message "Killed line")
      (list (line-beginning-position)
        (line-beginning-position 2)))))


;;----------------------------------------------------------------------------
;; Easily count words (http://emacs-fu.blogspot.com/2009/01/counting-words.html)
;;----------------------------------------------------------------------------
(defun count-words (&optional begin end)
  "count words between BEGIN and END (region); if no region defined, count words in buffer"
  (interactive "r")
  (let ((b (if mark-active begin (point-min)))
      (e (if mark-active end (point-max))))
    (message "Word count: %s" (how-many "\\w+" b e))))




(provide 'init-editing-utils)