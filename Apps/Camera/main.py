import cv2


def show_camera():
    # 0 là ID mặc định của camera laptop
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Error: Could not open camera.")
        return

    print("Press 'q' to quit.")

 while True:
        # Đọc từng khung hình (frame)
        ret, frame = cap.read()

        if not ret:
            print("Error: Can't receive frame.")
            break

        # Hiển thị khung hình trong cửa sổ 'Camera'
        cv2.imshow('Camera', frame)

        # Thoát nếu nhấn phím 'q'
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Giải phóng tài nguyên
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    show_camera()
