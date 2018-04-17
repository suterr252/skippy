;;;; src/polyline-decoder.lisp

;; For steps followed, see:
;; https://developers.google.com/maps/documentation/utilities/polylinealgorithm

(print "src/polyline-decoder.lisp eval'd")

(defparameter polyline "}ktwF|`ubMp@b@iBxF}BjHm@_@")
;; 0: {latitude: 40.74191, longitude: -74.00479}
;; 1: {latitude: 40.74166, longitude: -74.00497}
;; 2: {latitude: 40.74219, longitude: -74.00622}
;; 3: {latitude: 40.74282, longitude: -74.00772}
;; 4: {latitude: 40.74305, longitude: -74.00756}

(defun decode-line (polyline)
  (let ((index 0) (len (length polyline)) (lat 0) (lng 0) (dlat 0) (dlng 0))
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
        (print (list (* lat 0.00001) (* lng 0.00001)))))))

;; http://tomszilagyi.github.io/2016/01/CL-bitwise-Rosettacode
(defun shl (x width bits)
  "Compute bitwise left shift of x by 'bits' bits, represented on 'width' bits"
  (logand (ash x bits)
          (1- (ash 1 width))))

;; http://tomszilagyi.github.io/2016/01/CL-bitwise-Rosettacode
(defun shr (x width bits)
  "Compute bitwise right shift of x by 'bits' bits, represented on 'width' bits"
  (logand (ash x (- bits))
          (1- (ash 1 width))))
