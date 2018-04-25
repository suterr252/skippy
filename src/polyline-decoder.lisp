;;;; src/polyline-decoder.lisp

(in-package #:skippy)

(print "src/polyline-decoder.lisp eval'd")

(defun shl (x width bits)
  "Compute bitwise left shift of x by 'bits' bits, represented on 'width' bits"
  (logand (ash x bits)
          (1- (ash 1 width))))

(defun shr (x width bits)
  "Compute bitwise right shift of x by 'bits' bits, represented on 'width' bits"
  (logand (ash x (- bits))
          (1- (ash 1 width))))

(defun decode (polyline)
  "Steps as outlined here:
   https://developers.google.com/maps/documentation/utilities/polylinealgorithm"
  (let ((index 0)
        (len (length polyline))
        (lat 0) (lng 0)
        (dlat 0) (dlng 0)
        (coordinates ()))
    (loop while (< index len) do
      (let ((c 0) (b 0) (shift 0) (result 0))
        (setf c (char polyline index))
        (setf index (+ 1 index))
        (setf b (- (char-code c) 63))
        (setf result (logior result (shl (logand b #x1f) 32 shift)))
        (setf shift (+ shift 5))
        (loop while (>= b #x20) do
          (setf c (char polyline index))
          (setf index (+ 1 index))
          (setf b (- (char-code c) 63))
          (setf result (logior result (shl (logand b #x1f) 32 shift)))
          (setf shift (+ shift 5)))
        (setf dlat
              (if (/= 0 (logand result 1))
                  (lognot (shr result 32 1))
                  (shr result 32 1)))
        (setf lat (+ lat dlat))
        (setf shift 0)
        (setf result 0)
        (setf c (char polyline index))
        (setf index (+ 1 index))
        (setf b (- (char-code c) 63))
        (setf result (logior result (shl (logand b #x1f) 32 shift)))
        (setf shift (+ shift 5))
        (loop while (>= b #x20) do
          (setf c (char polyline index))
          (setf index (+ 1 index))
          (setf b (- (char-code c) 63))
          (setf result (logior result (shl (logand b #x1f) 32 shift)))
          (setf shift (+ shift 5)))
        (setf dlng
              (if (/= 0 (logand result 1))
                  (lognot (shr result 32 1))
                  (shr result 32 1)))
        (setf lng (+ lng dlng))
        (push (list (* lat 0.00001) (* lng 0.00001)) coordinates)
        ))
    (reverse coordinates)))
