import cv2
import tkinter as tk  # Bổ sung để lấy thông số màn hình


def show_camera():
    # 0 là ID mặc định của camera laptop
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Error: Could not open camera.")
        return

    # --- PHẦN BỔ SUNG: CĂN GIỮA MÀN HÌNH ---
    # 1. Lấy độ phân giải màn hình thực tế
    root = tk.Tk()
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    root.destroy()

    # 2. Định nghĩa kích thước cửa sổ (OpenCV mặc định thường là 640x480)
    cam_width, cam_height = 640, 480

    # 3. Tính toán tọa độ x, y để đặt vào chính giữa
    x = (screen_width // 2) - (cam_width // 2)
    y = (screen_height // 2) - (cam_height // 2)

    # 4. Khởi tạo cửa sổ và di chuyển
    cv2.namedWindow('Camera')
    cv2.moveWindow('Camera', x, y)
    # ---------------------------------------

    print("Press 'q' to quit.")

    while True:

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
