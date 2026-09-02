# 🚀 DevOps CI/CD Master - Khóa Học & Cẩm Nang Thực Chiến

Chào mừng bạn đến với **DevOps CI/CD Master** – Tài liệu và ghi chú học tập toàn diện về lộ trình DevOps từ cơ bản đến thực chiến, tập trung vào đóng gói ứng dụng (**Docker**), điều phối container (**Kubernetes**) và tự động hóa quy trình phân phối phần mềm (**CI/CD Pipelines**).

---

## 📚 Giới Thiệu Khóa Học & Nguồn Gốc

Tài liệu tiếng Việt này được tổng hợp, thực hành và đúc kết chi tiết dựa trên video bài giảng kinh điển:
* 🎥 **Video Tutorial gốc:** [JavaScript Mastery YouTube](https://www.youtube.com/watch?v=XUkNR-JfHwo)
* 🔗 **Repository thực hành dự án mẫu:** [https://github.com/giaphu39/acquisitions.git](https://github.com/giaphu39/acquisitions.git)

Toàn bộ nội dung trong khóa học được biên soạn kèm theo các ví dụ mã nguồn thực tế, giải thích bản chất kiến trúc và các "bẫy lỗi" thường gặp trên môi trường phát triển (đặc biệt là Windows WSL2 / Hyper-V).

---

## 🛠️ Các Công Nghệ Trọng Tâm Được Giảng Dạy

| Công Nghệ | Biểu Tượng | Vai Trò Trong Khóa Học |
| :--- | :---: | :--- |
| **YAML** | 📄 | Cú pháp cấu hình chuẩn hóa cho Docker Compose, Kubernetes manifests và GitHub Actions CI/CD workflows. |
| **Docker** | 🐳 | Nền tảng containerization hàng đầu, giúp đóng gói mã nguồn và môi trường chạy độc lập, đồng nhất. |
| **Dockerfile** | 📜 | Kỹ thuật viết chỉ dẫn build image chuẩn hóa, tối ưu hóa Layer Cache, quản lý phân quyền User phi root và bảo mật. |
| **Docker Compose** | 🐙 | Công cụ điều phối đa container (multi-container), thiết lập mạng nội bộ, quản trị volumes và cơ chế Hot Reload cho Dev. |
| **Kubernetes (K8s)**| ☸️ | Nền tảng orchestration quy mô lớn: quản lý vòng đời Pods, Deployments, Scaling, ReplicaSets và Services. |
| **Minikube & Kubectl** | 🎛️ | Thiết lập cụm Kubernetes cục bộ trên máy tính cá nhân để thực hành cấu hình và kiểm thử. |
| **CI/CD Automation** | 🚀 | Xây dựng pipeline tự động hóa quy trình kiểm thử (Linting, Testing) và triển khai ứng dụng tự động. |
| **PowerShell & Shell** | ⚡ | Tự động hóa kịch bản triển khai (Deployment Scripts) xuyên suốt hai nền tảng Windows và Linux. |

---

## 🗺️ Lộ Trình Học Tập & Tổng Quan Tài Liệu

Tất cả các bài học được sắp xếp theo trình tự mạch lạc, bạn có thể bấm trực tiếp vào các liên kết dưới đây để bắt đầu:

### 1. [1_YAML.md](./1_YAML.md) - Cú Pháp YAML Toàn Diện Cho DevOps
* Tìm hiểu các kiểu dữ liệu nền tảng trong YAML (Scalar, Sequences, Mappings).
* Nắm vững kỹ thuật nâng cao: **Anchors (`&`)**, **Aliases (`*`)**, và **Merge Keys (`<<`)** để tái sử dụng cấu hình không bị trùng lặp.
* Bảng so sánh trực quan giữa YAML và JSON, kèm các lưu ý quan trọng về thụt lề và khoảng trắng.

### 2. [2_1_DOCKER.md](./2_1_DOCKER.md) - Nền Tảng & Bản Chất Của Docker
* Khái niệm Containerization vs Virtual Machines (VMs), tại sao container lại nhẹ và khởi động tức thì.
* Kiến trúc Docker Engine: Docker Daemon, Docker Client, Docker Registries và Storage Drivers.
* Quy trình hoạt động của Image Layers và cơ chế Copy-on-Write (CoW).

### 3. [2_2_DOCKER_FILE.md](./2_2_DOCKER_FILE.md) - Nghệ Thuật Viết Dockerfile Chuẩn Production
* Hướng dẫn chi tiết từng chỉ dẫn: `FROM`, `WORKDIR`, `COPY`, `RUN`, `EXPOSE`, `CMD`, `ENTRYPOINT`.
* **Tối ưu Layer Caching:** Bí quyết tách riêng `package*.json` giúp rút ngắn thời gian build từ 5 phút xuống còn 1-2 giây.
* **Bảo mật phân quyền:** Thiết lập tài khoản phi root (`app:app`) và xử lý quyền sở hữu thư mục (`chown -R`).
* Khắc phục triệt để lỗi Hot Reload và lỗi phân quyền `EACCES: permission denied` khi mount code React (Vite).
* Hướng dẫn gắn tag và đẩy (push) image lên **Docker Hub**.

### 4. [2_3_DOCKER_COMPOSE.md](./2_3_DOCKER_COMPOSE.md) - Quản Trị Đa Container & Tự Động Hóa Với `docker init`
* Khởi tạo nhanh dự án với lệnh tương tác `docker init`.
* **Bản chất 2 dòng volume trong React Dev:** Phân biệt rõ rệt giữa **Bind Mount (`- .:/app`)** và **Anonymous Volume (`- /app/node_modules`)**.
* Giải mã bí ẩn về vòng đời dữ liệu: Docker copy `node_modules` từ Image vào Volume trống như thế nào.
* Phân biệt rõ cơ chế Hot Reload (Bind Mount + File Watcher) với Ports và Args.
* Bảng tra cứu toàn diện các lệnh Docker Compose (`up`, `stop`, `start`, `down`, `logs`, `scale`) và vòng đời container.

### 5. [3_1_KUBERNETES.md](./3_1_KUBERNETES.md) - Kiến Trúc & Các Thành Phần Cốt Lõi Kubernetes
* Tổng quan kiến trúc K8s: Control Plane (API Server, etcd, Scheduler, Controller Manager) và Worker Nodes (Kubelet, Kube-proxy, Container Runtime).
* Phân biệt các tài nguyên cốt lõi: **Pods**, **ReplicaSets**, **Deployments**.
* Các giải pháp mạng trong K8s: **ClusterIP**, **NodePort**, **LoadBalancer** và **Ingress**.

### 6. [3_2_KUBERNETES_DEMO.md](./3_2_KUBERNETES_DEMO.md) - Thực Hành Triển Khai Ứng Dụng Lên Minikube
* Cài đặt và thiết lập Minikube trên máy tính cá nhân.
* Viết tệp khai báo [`deployment.yaml`](./3_1_Kubernetes-demo/k8s/deployment.yaml) và [`services.yaml`](./3_1_Kubernetes-demo/k8s/services.yaml).
* Kịch bản tự động hóa triển khai bằng script: [`deploy.sh`](./3_1_Kubernetes-demo/deploy.sh) (Linux/macOS) và [`deploy.ps1`](./3_1_Kubernetes-demo/deploy.ps1) (Windows).
* Giám sát trạng thái Pod, Rollout Updates và Rollback ứng dụng khi gặp sự cố.

### 7. [3_3_POWERSHELL.md](./3_3_POWERSHELL.md) - PowerShell Scripting Dành Cho DevOps Trên Windows
* Hướng dẫn sử dụng PowerShell tự động hóa các tác vụ quản trị và triển khai.
* So sánh các lệnh tương đương giữa PowerShell, CMD và Bash Linux.
* Kỹ thuật xử lý lỗi, biến môi trường và quản lý tiến trình nền.

---

## 🤝 Đóng Góp & Phát Triển Khóa Học (Contribution)

Khóa học này là một dự án mở, luôn hoan nghênh mọi đóng góp, sửa lỗi chính tả, bổ sung ví dụ thực tế hoặc cải tiến nội dung từ cộng đồng.

### Cách 1: Đóng góp qua GitHub Flow (Khuyên Dùng)
1. **Fork** repository này về tài khoản GitHub của bạn.
2. Clone repo về máy cục bộ:
   ```bash
   git clone https://github.com/<your-username>/CI-CD-Master.git
   ```
3. Tạo một nhánh mới (branch) cho tính năng hoặc nội dung bạn muốn chỉnh sửa:
   ```bash
   git checkout -b feature/ten-dong-gop
   ```
4. Thực hiện các chỉnh sửa, bổ sung nội dung và commit:
   ```bash
   git commit -m "docs: cập nhật bổ sung ví dụ thực tế cho Docker Compose"
   ```
5. Đẩy nhánh lên fork của bạn:
   ```bash
   git push origin feature/ten-dong-gop
   ```
6. Mở một **Pull Request (PR)** trên repo gốc và mô tả chi tiết nội dung đóng góp của bạn.

### Cách 2: Trở thành Cộng Tác Viên Trực Tiếp (Direct Collaborator)
Nếu bạn muốn đóng góp lâu dài hoặc thảo luận phát triển thêm các module mới:
* Hãy nhắn tin trực tiếp cho mình qua tài khoản GitHub hoặc các kênh liên hệ.
* Mình sẽ add tài khoản của bạn trực tiếp vào danh sách **Collaborators** của repo để cùng nhau chỉnh sửa và phát triển tài liệu nhanh chóng hơn!

---

⭐ **Nếu thấy tài liệu này hữu ích, hãy để lại một Star ủng hộ repo nhé! Chúc bạn học tập hiệu quả trên con đường chinh phục DevOps & CI/CD or FULLSTACK/AI ENGINEER!**
